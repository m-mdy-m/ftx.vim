" Copyright (c) 2026 m-mdy-m
" MIT License

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'ftx'

call ftx#ui#style#Syntax()

augroup ftx_syntax
  autocmd! * <buffer>
  autocmd ColorScheme <buffer> call ftx#ui#style#Highlight()
augroup END

call ftx#ui#style#Highlight()