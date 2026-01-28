" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#git#statusline#render() abort
  let parts = []
  call add(parts, s:get_project_name())
  if get(g:, 'ftx_enable_git', 1)
    let git_info = s:get_git_info()
    if !empty(git_info)
      call add(parts, git_info)
    endif
  endif
  
  " Mark count
  if get(g:, 'ftx_enable_marks', 1)
    let mark_count = ftx#tree#marks#count()
    if mark_count > 0
      call add(parts, printf('%s %d', get(g:, 'ftx_icon_marked', '✓'), mark_count))
    endif
  endif
  
  return join(parts, ' ')
endfunction

function! s:get_project_name() abort
  let root = ftx#tree#tree#get_root()
  if empty(root)
    return 'FTX'
  endif
  
  let name = fnamemodify(root, ':t')
  if empty(name)
    let name = fnamemodify(root, ':h:t')
  endif
  
  return '[' . name . ']'
endfunction

function! s:get_git_info() abort
  let info = ftx#git#branch#get_info()
  
  if empty(info.branch)
    return ''
  endif
  
  let parts = ['(' . info.branch . ')']
  let status_summary = s:get_status_summary()
  if !empty(status_summary)
    call add(parts, status_summary)
  endif
  if info.ahead > 0
    call add(parts, '↑' . info.ahead)
  endif
  
  if info.behind > 0
    call add(parts, '↓' . info.behind)
  endif
  if info.has_stash
    call add(parts, '$')
  endif
  
  return join(parts, ' ')
endfunction

function! s:get_status_summary() abort
  let all_status = ftx#git#status#get_all()
  if empty(all_status)
    return ''
  endif
  
  let counts = {
        \ 'modified': 0,
        \ 'added': 0,
        \ 'deleted': 0,
        \ 'untracked': 0,
        \ 'conflict': 0,
        \}
  
  for [path, xy] in items(all_status)
    if len(xy) != 2
      continue
    endif
    if xy =~# '^\%(DD\|AU\|UD\|UA\|DU\|AA\|UU\)$'
      let counts.conflict += 1
      continue
    endif
    if xy ==# '??'
      let counts.untracked += 1
      continue
    endif
    
    let x = xy[0]
    let y = xy[1]
    if x ==# 'M' || y ==# 'M'
      let counts.modified += 1
    endif
    if x ==# 'A'
      let counts.added += 1
    endif
    if x ==# 'D' || y ==# 'D'
      let counts.deleted += 1
    endif
  endfor
  
  let parts = []
  
  if counts.conflict > 0
    call add(parts, get(g:, 'ftx_git_icon_unmerged', '!') . counts.conflict)
  endif
  
  if counts.modified > 0
    call add(parts, get(g:, 'ftx_git_icon_modified', '*') . counts.modified)
  endif
  
  if counts.added > 0
    call add(parts, get(g:, 'ftx_git_icon_added', '+') . counts.added)
  endif
  
  if counts.deleted > 0
    call add(parts, get(g:, 'ftx_git_icon_deleted', '-') . counts.deleted)
  endif
  
  if counts.untracked > 0
    call add(parts, get(g:, 'ftx_git_icon_untracked', '?') . counts.untracked)
  endif
  
  if empty(parts)
    return ''
  endif
  
  return '[' . join(parts, ' ') . ']'
endfunction