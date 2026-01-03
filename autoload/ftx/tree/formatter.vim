" Copyright (c) 2026 m-mdy-m
" MIT License
" Node formatting

function! ftx#tree#formatter#Format(node) abort
  let parts = []
  
  " Indentation
  call add(parts, repeat('  ', a:node.depth))
  
  " Icon
  call add(parts, ftx#tree#node#GetIcon(a:node))
  
  " Mark indicator
  let mark = ftx#tree#node#GetMarkIcon(a:node)
  if !empty(mark)
    call add(parts, mark)
  endif
  
  " Git status
  let git = ftx#tree#node#GetGitIcon(a:node)
  if !empty(git)
    call add(parts, git)
  endif
  
  " Name
  call add(parts, a:node.name)
  
  return join(parts, '')
endfunction

function! ftx#tree#formatter#FormatAll(nodes) abort
  let lines = []
  for node in a:nodes
    call add(lines, ftx#tree#formatter#Format(node))
  endfor
  return lines
endfunction