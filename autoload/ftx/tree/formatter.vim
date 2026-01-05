" Copyright (c) 2026 m-mdy-m
" MIT License

function! ftx#tree#formatter#Format(node) abort
  let parts = []
  
  call add(parts, repeat('  ', a:node.depth))
  let s:icon = ftx#ui#icons#GetForNode(a:node)
  if !empty(s:icon)
    call add(parts, s:icon . ' ')
  endif
  let git = ftx#tree#node#GetGitIcon(a:node)
  if !empty(git)
    call add(parts, git . ' ')
  endif
  let mark = ftx#tree#node#GetMarkIcon(a:node)
  if !empty(mark)
    call add(parts, mark . ' ')
  endif
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