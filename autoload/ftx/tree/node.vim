" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#tree#node#create(path, depth) abort
  let name = fnamemodify(a:path, ':t')
  let is_dir = isdirectory(a:path)
  
  let node = {
        \ 'path': a:path,
        \ 'name': name,
        \ 'depth': a:depth,
        \ 'is_dir': is_dir,
        \ 'is_expanded': 0,
        \ 'is_link': getftype(a:path) ==# 'link',
        \ 'git_status': '',
        \}
  
  return node
endfunction