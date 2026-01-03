" Copyright (c) 2026 m-mdy-m
" MIT License

function! ftx#style#Syntax() abort
  syntax clear
  
  syntax match FTXDirIcon /[▸▾]/ contained
  syntax match FTXDir /^[[:space:]]*[▸▾][[:space:]]\+.*$/ contains=FTXDirIcon,FTXGitSymbol
  
  syntax match FTXFile /^[[:space:]]\{2\}[[:space:]]*[+*?\-!]\?[[:space:]]*[^▸▾].*$/ contains=FTXGitSymbol
  
  syntax match FTXGitSymbol /[+*?\-!]/ contained
  
  syntax match FTXGitStaged /+/ contained
  syntax match FTXGitModified /\*/ contained
  syntax match FTXGitUntracked /?/ contained
  syntax match FTXGitDeleted /-/ contained
  syntax match FTXGitConflict /!/ contained
endfunction

function! ftx#style#Highlight() abort
  highlight default link FTXDir Directory
  highlight default link FTXDirIcon Comment
  highlight default link FTXFile Normal
  
  highlight default FTXGitStaged ctermfg=2 guifg=#5faf5f gui=bold
  highlight default FTXGitModified ctermfg=3 guifg=#d7af5f gui=bold
  highlight default FTXGitUntracked ctermfg=8 guifg=#808080
  highlight default FTXGitDeleted ctermfg=1 guifg=#d75f5f gui=bold
  highlight default FTXGitConflict ctermfg=5 guifg=#af5fd7 gui=bold
  highlight default link FTXGitSymbol FTXGitModified
endfunction