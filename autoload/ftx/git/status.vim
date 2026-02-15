" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
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
  
  let interval = get(g:, 'ftx_git_update_time', 2000)
  let s:state.update_timer = timer_start(interval, function('s:on_timer'), {'repeat': -1})
  
  return a:root
endfunction

function! s:on_timer(timer) abort
  if empty(s:state.root) || !ftx#is_open()
    return
  endif
  call s:update_status(s:state.root)
endfunction

function! s:update_status(root) abort
  if s:state.job isnot v:null
    call s:stop_job()
  endif
  
  let cmd = ['git', '-C', a:root, 'status', '--porcelain=v1', '-b']
  
  if !get(g:, 'ftx_show_ignored', 0)
    call add(cmd, '--ignored=no')
  else
    call add(cmd, '--ignored=matching')
  endif
  
  return ftx#async#job#run(cmd, {'cwd': a:root})
        \.then({lines -> s:parse_status(a:root, lines)})
        \.then({cache -> s:finalize(cache)})
        \.catch({err -> {}})
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
    
    let xy = line[0:1]
    let file = s:extract_file(line[3:])
    let path = a:root . '/' . file
    let cache[path] = s:merge_status(get(cache, path, ''), xy)
    call s:mark_parents(cache, a:root, path, xy)
  endfor
  
  return cache
endfunction

function! s:extract_file(str) abort
  return substitute(a:str, ' -> .*', '', '')
endfunction

function! s:mark_parents(cache, root, path, xy) abort
  let dir = ftx#helpers#path#dirname(a:path)

  while dir !=# a:root && dir !=# '/'
    let a:cache[dir] = s:merge_status(get(a:cache, dir, ''), a:xy)
    let dir = ftx#helpers#path#dirname(dir)
  endwhile
endfunction

function! s:merge_status(current, incoming) abort
  if empty(a:current)
    return a:incoming
  endif
  if empty(a:incoming)
    return a:current
  endif

  if a:current =~# 'U' || a:incoming =~# 'U'
    return 'UU'
  endif

  if a:current ==# '!!' && a:incoming ==# '!!'
    return '!!'
  endif
  if (a:current ==# '??' || a:incoming ==# '??')
    if a:current =~# '[MADRCTU]' || a:incoming =~# '[MADRCTU]'
      " Mixed tracked + untracked changes.
      return s:merge_xy(a:current, a:incoming)
    endif
    return '??'
  endif

  return s:merge_xy(a:current, a:incoming)
endfunction

function! s:merge_xy(current, incoming) abort
  let x = s:pick_index(a:current[0], a:incoming[0])
  let y = s:pick_worktree(a:current[1], a:incoming[1])
  return x . y
endfunction

function! s:pick_index(left, right) abort
  let weights = {
        \ ' ': 0,
        \ '!': 1,
        \ '?': 2,
        \ 'A': 3,
        \ 'C': 4,
        \ 'R': 5,
        \ 'M': 6,
        \ 'D': 7,
        \ 'U': 8,
        \ }
  return get(weights, a:left, 0) >= get(weights, a:right, 0) ? a:left : a:right
endfunction

function! s:pick_worktree(left, right) abort
  let weights = {
        \ ' ': 0,
        \ '!': 1,
        \ '?': 2,
        \ 'T': 3,
        \ 'M': 4,
        \ 'D': 5,
        \ 'U': 6,
        \ }
  return get(weights, a:left, 0) >= get(weights, a:right, 0) ? a:left : a:right
endfunction

function! s:finalize(cache) abort
  let s:state.cache = a:cache
  
  if ftx#is_open()
    call ftx#refresh({'force': 0})
  endif
  
  return a:cache
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

function! ftx#git#status#get_raw(path) abort
  return get(s:state.cache, a:path, '')
endfunction

function! ftx#git#status#get(path) abort
  let xy = ftx#git#status#get_raw(a:path)
  if empty(xy) || len(xy) != 2
    return ''
  endif

  if get(g:, 'ftx_git_status_style', 'icon') ==# 'xy'
    return xy
  endif
  
  let custom = get(g:, 'ftx_git_status_icons', {})
  if has_key(custom, xy)
    return custom[xy]
  endif
  
  return s:get_default_icon(xy)
endfunction

function! s:get_default_icon(xy) abort
  if a:xy =~# '^\%(DD\|AU\|UD\|UA\|DU\|AA\|UU\)$'
    return get(g:, 'ftx_git_icon_unmerged', '!')
  endif
  
  if a:xy ==# '??'
    return get(g:, 'ftx_git_icon_untracked', '?')
  endif
  if a:xy ==# '!!'
    return get(g:, 'ftx_git_icon_ignored', '◌')
  endif
  
  let x = a:xy[0]
  let y = a:xy[1]
  
  " Worktree changes have priority (what you see in files)
  if y ==# 'M'
    return get(g:, 'ftx_git_icon_modified', '*')
  elseif y ==# 'D'
    return get(g:, 'ftx_git_icon_deleted', '-')
  elseif y ==# 'T'
    return get(g:, 'ftx_git_icon_modified', '*')
  endif
  
  " Index changes (staged)
  if x ==# 'M'
    return get(g:, 'ftx_git_icon_modified', '*')
  elseif x ==# 'A'
    return get(g:, 'ftx_git_icon_added', '+')
  elseif x ==# 'D'
    return get(g:, 'ftx_git_icon_deleted', '-')
  elseif x ==# 'R'
    return get(g:, 'ftx_git_icon_renamed', '→')
  elseif x ==# 'C'
    return get(g:, 'ftx_git_icon_renamed', '→')
  endif
  
  return ''
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