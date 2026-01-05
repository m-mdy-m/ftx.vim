" Copyright (c) 2026 m-mdy-m
" MIT License

if exists('b:current_syntax')
  finish
endif

call ftx#ui#style#Apply()

augroup FTXSyntax
  autocmd! * <buffer>
  autocmd ColorScheme <buffer> call ftx#ui#style#Highlight()
augroup END

let b:current_syntax = 'ftx'