" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:bufnr = -1

function! ftx#internal#buffer#create() abort
  let bufname = 'FTX_' . localtime()
  
  enew
  let s:bufnr = bufnr('%')
  execute 'silent! file ' . bufname
  
  return s:bufnr
endfunction

function! ftx#internal#buffer#get() abort
  return s:bufnr
endfunction

function! ftx#internal#buffer#exists() abort
  return s:bufnr != -1 && bufexists(s:bufnr)
endfunction

function! ftx#internal#buffer#is_visible() abort
  return ftx#internal#buffer#winid() != -1
endfunction

function! ftx#internal#buffer#winid() abort
  if !ftx#internal#buffer#exists()
    return -1
  endif
  return bufwinid(s:bufnr)
endfunction

function! ftx#internal#buffer#clear() abort
  let s:bufnr = -1
endfunction