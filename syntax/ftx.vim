" Copyright (c) 2025 m-mdy-m
" MIT License

if exists('b:current_syntax')
  finish
endif

let b:current_syntax = 'ftx'

call ftx#style#Syntax()

augroup ftx_syntax
  autocmd! * <buffer>
  autocmd ColorScheme <buffer> call ftx#style#Highlight()
augroup END

call ftx#style#Highlight()