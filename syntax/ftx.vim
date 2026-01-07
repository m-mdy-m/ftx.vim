" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'ftx'

function! s:setup_syntax() abort
  let renderer = ftx#renderer#default#new()
  call renderer.syntax()
  call renderer.highlight()
endfunction

function! s:refresh_highlights() abort
  let renderer = ftx#renderer#default#new()
  call renderer.highlight()
endfunction

call s:setup_syntax()
augroup ftx_syntax
  autocmd! * <buffer>
  autocmd ColorScheme <buffer> call s:refresh_highlights()
augroup END