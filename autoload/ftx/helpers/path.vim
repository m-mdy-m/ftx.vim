" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#helpers#path#normalize(path) abort
  let sep = ftx#helpers#platform#separator()
  let path = substitute(a:path, '[/\\]', sep, 'g')
  let path = substitute(path, sep . sep . '+', sep, 'g')
  return path
endfunction

function! ftx#helpers#path#join(...) abort
  let sep = ftx#helpers#platform#separator()
  return join(a:000, sep)
endfunction

function! ftx#helpers#path#dirname(path) abort
  return fnamemodify(a:path, ':h')
endfunction

function! ftx#helpers#path#basename(path) abort
  return fnamemodify(a:path, ':t')
endfunction

function! ftx#helpers#path#abspath(path) abort
  return fnamemodify(a:path, ':p')
endfunction

function! ftx#helpers#path#exists(path) abort
  return filereadable(a:path) || isdirectory(a:path)
endfunction

function! ftx#helpers#path#is_directory(path) abort
  return isdirectory(a:path)
endfunction

function! ftx#helpers#path#is_readable(path) abort
  return filereadable(a:path)
endfunction