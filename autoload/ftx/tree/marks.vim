" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:marks = {}

function! ftx#tree#marks#mark(path, node) abort
  let s:marks[a:path] = a:node
endfunction

function! ftx#tree#marks#unmark(path) abort
  if has_key(s:marks, a:path)
    unlet s:marks[a:path]
  endif
endfunction

function! ftx#tree#marks#is_marked(path) abort
  return has_key(s:marks, a:path)
endfunction

function! ftx#tree#marks#get_all() abort
  return s:marks
endfunction

function! ftx#tree#marks#count() abort
  return len(s:marks)
endfunction

function! ftx#tree#marks#clear() abort
  let s:marks = {}
endfunction