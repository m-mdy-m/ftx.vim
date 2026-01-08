" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#mapping#yank#path(type) abort
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node)
    return
  endif
  
  let path = s:get_path(node, a:type)
  if has('clipboard')
    call setreg('+', path)
  endif
  call setreg('"', path)
  
  call ftx#helpers#logger#info('Yanked: ' . path)
endfunction

function! s:get_path(node, type) abort
  if a:type ==# 'absolute'
    return a:node.path
  elseif a:type ==# 'relative'
    return s:get_relative_path(a:node.path)
  elseif a:type ==# 'name'
    return a:node.name
  else
    return a:node.path
  endif
endfunction

function! s:get_relative_path(path) abort
  let root = ftx#tree#tree#get_root()
  let path = a:path
  
  if path[:len(root)-1] ==# root
    let path = path[len(root):]
    let path = substitute(path, '^/', '', '')
  endif
  
  return path
endfunction

function! ftx#mapping#yank#absolute() abort
  call ftx#mapping#yank#path('absolute')
endfunction

function! ftx#mapping#yank#relative() abort
  call ftx#mapping#yank#path('relative')
endfunction

function! ftx#mapping#yank#name() abort
  call ftx#mapping#yank#path('name')
endfunction