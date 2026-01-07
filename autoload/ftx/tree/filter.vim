" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#tree#filter#apply(entries, predicates) abort
  let result = a:entries
  
  for Predicate in a:predicates
    let result = filter(copy(result), {_, e -> Predicate(e)})
  endfor
  
  return result
endfunction

function! ftx#tree#filter#hidden() abort
  if get(g:, 'ftx_show_hidden', 0)
    return {entry -> 1}
  endif
  
  return {entry -> entry.name[0] !=# '.'}
endfunction

function! ftx#tree#filter#pattern(pattern) abort
  return {entry -> entry.name =~? a:pattern}
endfunction

function! ftx#tree#filter#extension(ext) abort
  return {entry -> !entry.is_dir && fnamemodify(entry.name, ':e') ==? a:ext}
endfunction

function! ftx#tree#filter#directory() abort
  return {entry -> entry.is_dir}
endfunction

function! ftx#tree#filter#file() abort
  return {entry -> !entry.is_dir}
endfunction