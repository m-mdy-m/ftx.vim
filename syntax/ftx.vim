" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'ftx'

syntax clear

function! s:syntax() abort
  let renderer = ftx#renderer#default#new()
  call renderer.syntax()
endfunction

function! s:highlight() abort
  let renderer = ftx#renderer#default#new()
  call renderer.highlight()
endfunction

augroup ftx_syntax_internal
  autocmd! * <buffer>
  autocmd ColorScheme <buffer> call s:highlight()
augroup END

call s:highlight()
call s:syntax()