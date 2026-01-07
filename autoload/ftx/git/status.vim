" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Git status management with async operations and caching
" ----------------------------------------------------------------------

let s:state = {
      \ 'root': '',
      \ 'cache': {},
      \ 'job': v:null,
      \ 'update_timer': -1,
      \}

function! ftx#git#status#init(path) abort
  if !get(g:, 'ftx_enable_git', 1) || !get(g:, 'ftx_git_status', 1)
    return ftx#async#promise#resolve({})
  endif
  
  if !executable('git')
    call ftx#helpers#logger#warn('Git not found')
    return ftx#async#promise#resolve({})
  endif
  
  return s:find_root(a:path)
        \.then({root -> s:setup_tracking(root)})
        \.then({root -> s:update_status(root)})
        \.catch({err -> ftx#async#promise#resolve({})})
endfunction

function! s:find_root(path) abort
  let cached = ftx#tree#cache#get('git:root:' . a:path)
  if cached isnot v:null
    return ftx#async#promise#resolve(cached)
  endif
  
  let path = fnamemodify(a:path, ':p:h')
  let depth = 0
  
  while path !=# '/' && path !=# '' && depth < 20
    if isdirectory(path . '/.git')
      call ftx#tree#cache#set('git:root:' . a:path, path)
      return ftx#async#promise#resolve(path)
    endif
    let path = ftx#helpers#path#dirname(path)
    let depth += 1
  endwhile
  
  return ftx#async#promise#reject('Not in git repository')
endfunction

function! s:setup_tracking(root) abort
  let s:state.root = a:root
  
  if s:state.update_timer != -1
    call timer_stop(s:state.update_timer)
  endif
  
  let interval = get(g:, 'ftx_git_update_time', 1000)
  let s:state.update_timer = timer_start(interval, function('s:on_timer'), {'repeat': -1})
  
  return a:root
endfunction

function! s:on_timer(timer) abort
  if empty(s:state.root)
    return
  endif
  call s:update_status(s:state.root)
endfunction

function! s:update_status(root) abort
  if s:state.job isnot v:null
    call s:stop_job()
  endif
  
  let cmd = ['git', '-C', a:root, 'status', '--porcelain=v1', '-b', '--ignored']
  
  return ftx#async#job#run(cmd, {'cwd': a:root})
        \.then({lines -> s:parse_status(a:root, lines)})
        \.then({cache -> s:finalize(cache)})
        \.catch({err -> s:handle_error(err)})
endfunction

function! s:parse_status(root, lines) abort
  let cache = {}
  
  for line in a:lines
    if empty(line)
      continue
    endif
    
    if line[0:1] ==# '##'
      call ftx#git#branch#parse(line)
      continue
    endif
    
    let status = line[0:1]
    let file = s:extract_file(line[3:])
    let path = a:root . '/' . file
    
    let icon = s:get_icon(status)
    if !empty(icon)
      let cache[path] = icon
      call s:mark_parents(cache, a:root, path, icon)
    endif
  endfor
  
  return cache
endfunction

function! s:extract_file(str) abort
  return substitute(a:str, ' -> .*', '', '')
endfunction

function! s:get_icon(status) abort
  if a:status[0:1] ==# '!!'
    return get(g:, 'ftx_show_ignored', 0) 
          \ ? get(g:, 'ftx_git_icon_ignored', '◌')
          \ : ''
  endif
  
  let x = a:status[0]
  let y = a:status[1]
  
  if x ==# 'A' || y ==# 'A'
    return get(g:, 'ftx_git_icon_added', '+')
  elseif x ==# 'M' || y ==# 'M'
    return get(g:, 'ftx_git_icon_modified', '*')
  elseif x ==# 'D' || y ==# 'D'
    return get(g:, 'ftx_git_icon_deleted', '-')
  elseif x ==# 'R' || y ==# 'R'
    return get(g:, 'ftx_git_icon_renamed', '→')
  elseif a:status ==# '??'
    return get(g:, 'ftx_git_icon_untracked', '?')
  elseif x ==# 'U' || y ==# 'U'
    return get(g:, 'ftx_git_icon_unmerged', '!')
  endif
  
  return ''
endfunction

function! s:mark_parents(cache, root, path, icon) abort
  let dir = ftx#helpers#path#dirname(a:path)
  
  while dir !=# a:root && dir !=# '/'
    if !has_key(a:cache, dir)
      let a:cache[dir] = a:icon
    endif
    let dir = ftx#helpers#path#dirname(dir)
  endwhile
endfunction

function! s:finalize(cache) abort
  let s:state.cache = a:cache
  
  if ftx#is_open()
    call ftx#refresh({'force': 0})
  endif
  
  return a:cache
endfunction

function! s:handle_error(err) abort
  call ftx#helpers#logger#error('Git status failed', a:err)
  return {}
endfunction

function! s:stop_job() abort
  if s:state.job isnot v:null
    try
      call job_stop(s:state.job)
    catch
    endtry
    let s:state.job = v:null
  endif
endfunction

function! ftx#git#status#get(path) abort
  return get(s:state.cache, a:path, '')
endfunction

function! ftx#git#status#get_all() abort
  return copy(s:state.cache)
endfunction

function! ftx#git#status#get_root() abort
  return s:state.root
endfunction

function! ftx#git#status#refresh() abort
  if empty(s:state.root)
    return ftx#async#promise#resolve({})
  endif
  
  return s:update_status(s:state.root)
        \.then({_ -> ftx#refresh()})
        \.catch({err -> ftx#helpers#logger#error('Refresh failed', err)})
endfunction

function! ftx#git#status#cleanup() abort
  call s:stop_job()
  
  if s:state.update_timer != -1
    call timer_stop(s:state.update_timer)
    let s:state.update_timer = -1
  endif
  
  let s:state = {
        \ 'root': '',
        \ 'cache': {},
        \ 'job': v:null,
        \ 'update_timer': -1,
        \}
endfunction