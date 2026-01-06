" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

let s:cache = {}

function! ftx#helpers#platform#is_windows() abort
  if !has_key(s:cache, 'is_windows')
    let s:cache.is_windows = has('win32') || has('win64')
  endif
  return s:cache.is_windows
endfunction

function! ftx#helpers#platform#is_mac() abort
  if !has_key(s:cache, 'is_mac')
    let s:cache.is_mac = has('mac') || has('macunix')
  endif
  return s:cache.is_mac
endfunction

function! ftx#helpers#platform#is_unix() abort
  if !has_key(s:cache, 'is_unix')
    let s:cache.is_unix = has('unix')
  endif
  return s:cache.is_unix
endfunction

function! ftx#helpers#platform#separator() abort
  if !has_key(s:cache, 'separator')
    let s:cache.separator = ftx#helpers#platform#is_windows() ? '\' : '/'
  endif
  return s:cache.separator
endfunction