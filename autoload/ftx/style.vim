" Copyright (c) 2025 m-mdy-m
" MIT License

function! ftx#style#Syntax() abort
  syntax clear
  
  syntax match FTXDir           /^[│ ]*[▸▾] \zs.*$/
  syntax match FTXFile          /^[│ ]*  \zs[^*+?$↑↓]*$/
  syntax match FTXIcon          /^[│ ]*[▸▾]/
  syntax match FTXIndent         /^[│ ]*/
  
  syntax match FTXGitModified   /\*/ contained
  syntax match FTXGitStaged     /+/ contained
  syntax match FTXGitUntracked  /?/ contained
  syntax match FTXGitStashed    /\$/ contained
  syntax match FTXGitAhead      /↑\d\+/ contained
  syntax match FTXGitBehind     /↓\d\+/ contained
  
  syntax match FTXGitStatus     /[*+?$↑↓]\+\d*/ contains=FTXGitModified,FTXGitStaged,FTXGitUntracked,FTXGitStashed,FTXGitAhead,FTXGitBehind
endfunction

function! ftx#style#Highlight() abort
  highlight default link FTXDir     Directory
  highlight default link FTXFile    Normal
  highlight default link FTXIcon    Comment
  highlight default link FTXIndent  Comment
  
  highlight default FTXGitModified  ctermfg=180 guifg=#d08030
  highlight default FTXGitStaged    ctermfg=77  guifg=#70c070
  highlight default FTXGitUntracked ctermfg=242 guifg=#6a6a6a
  highlight default FTXGitStashed   ctermfg=141 guifg=#a090c7
  highlight default FTXGitAhead     ctermfg=77  guifg=#70c070
  highlight default FTXGitBehind    ctermfg=167 guifg=#e06060
endfunction