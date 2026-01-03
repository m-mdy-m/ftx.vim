" Copyright (c) 2026 m-mdy-m
" MIT License

" Find suitable window for opening files
function! ftx#utils#FindSuitableWindow() abort
  let ftx_bufnr = ftx#GetBufnr()
  
  for winnr in range(1, winnr('$'))
    let bufnr = winbufnr(winnr)
    
    if bufnr == ftx_bufnr
      continue
    endif
    
    if getbufvar(bufnr, '&buftype') ==# ''
      return winnr
    endif
  endfor
  
  return -1
endfunction

" String padding
function! ftx#utils#PadRight(str, width) abort
  let str = a:str
  while strwidth(str) < a:width
    let str .= ' '
  endwhile
  return str
endfunction

function! ftx#utils#Truncate(str, width) abort
  if strwidth(a:str) <= a:width
    return ftx#utils#PadRight(a:str, a:width)
  endif
  return a:str[:(a:width - 4)] . '...'
endfunction

" Path operations
function! ftx#utils#GetParentDir(path) abort
  return fnamemodify(a:path, ':h')
endfunction

function! ftx#utils#GetBasename(path) abort
  return fnamemodify(a:path, ':t')
endfunction

function! ftx#utils#IsDirectory(path) abort
  return isdirectory(a:path)
endfunction

function! ftx#utils#IsReadable(path) abort
  return filereadable(a:path)
endfunction

" File type detection
function! ftx#utils#GetFileType(path) abort
  return getftype(a:path)
endfunction

function! ftx#utils#IsSymlink(path) abort
  return ftx#utils#GetFileType(a:path) ==# 'link'
endfunction

" Echo helpers
function! ftx#utils#EchoError(msg) abort
  echohl ErrorMsg
  echo '[FTX] ' . a:msg
  echohl None
endfunction

function! ftx#utils#EchoWarning(msg) abort
  echohl WarningMsg
  echo '[FTX] ' . a:msg
  echohl None
endfunction

function! ftx#utils#EchoInfo(msg) abort
  echo '[FTX] ' . a:msg
endfunction

function! ftx#utils#EchoSuccess(msg) abort
  echohl MoreMsg
  echo '[FTX] ' . a:msg
  echohl None
endfunction