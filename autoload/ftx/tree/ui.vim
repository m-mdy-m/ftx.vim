" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:current_nodes = []

function! ftx#tree#ui#set_nodes(nodes) abort
  let s:current_nodes = a:nodes
endfunction

function! ftx#tree#ui#get_all_nodes() abort
  return s:current_nodes
endfunction

function! ftx#tree#ui#get_cursor_node() abort
  let lnum = line('.')
  
  if lnum < 1 || lnum > len(s:current_nodes)
    return {}
  endif
  
  return s:current_nodes[lnum - 1]
endfunction

function! ftx#tree#ui#find_node_by_path(path) abort
  for node in s:current_nodes
    if node.path ==# a:path
      return node
    endif
  endfor
  
  return {}
endfunction

function! ftx#tree#ui#get_lnum_by_path(path) abort
  for i in range(len(s:current_nodes))
    if s:current_nodes[i].path ==# a:path
      return i + 1
    endif
  endfor
  
  return 0
endfunction

function! ftx#tree#ui#focus_node(path) abort
  let lnum = ftx#tree#ui#get_lnum_by_path(a:path)
  
  if lnum > 0
    call cursor(lnum, 1)
    normal! zz
  endif
endfunction

function! ftx#tree#ui#save_cursor() abort
  return [line('.'), col('.')]
endfunction

function! ftx#tree#ui#restore_cursor(pos) abort
  call cursor(a:pos[0], a:pos[1])
endfunction

function! ftx#tree#ui#clear() abort
  let s:current_nodes = []
endfunction