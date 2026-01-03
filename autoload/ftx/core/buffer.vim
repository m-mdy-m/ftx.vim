" Copyright (c) 2026 m-mdy-m
" MIT License
" Buffer management

let s:bufnr = -1
let s:bufname_counter = 0

function! ftx#core#buffer#Create() abort
  let s:bufname_counter += 1
  let bufname = 'FTX_' . s:bufname_counter
  
  enew
  let s:bufnr = bufnr('%')
  
  " Buffer settings
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal nonumber
  setlocal norelativenumber
  setlocal signcolumn=no
  setlocal foldcolumn=0
  setlocal nomodeline
  setlocal nofoldenable
  setlocal cursorline
  setlocal filetype=ftx
  
  execute 'silent! file ' . bufname
  
  return s:bufnr
endfunction

function! ftx#core#buffer#Get() abort
  return s:bufnr
endfunction

function! ftx#core#buffer#Exists() abort
  return s:bufnr != -1 && bufexists(s:bufnr)
endfunction

function! ftx#core#buffer#GetWinId() abort
  if !ftx#core#buffer#Exists()
    return -1
  endif
  return bufwinid(s:bufnr)
endfunction

function! ftx#core#buffer#IsVisible() abort
  return ftx#core#buffer#GetWinId() != -1
endfunction

function! ftx#core#buffer#SetModifiable(state) abort
  let winid = ftx#core#buffer#GetWinId()
  if winid == -1
    return
  endif
  
  let cmd = a:state ? 'setlocal modifiable' : 'setlocal nomodifiable'
  call win_execute(winid, cmd)
endfunction

function! ftx#core#buffer#Clear() abort
  let s:bufnr = -1
endfunction

function! ftx#core#buffer#SetLines(lines) abort
  let bufnr = ftx#core#buffer#Get()
  let winid = ftx#core#buffer#GetWinId()
  
  if bufnr == -1 || winid == -1
    return
  endif
  
  call ftx#core#buffer#SetModifiable(1)
  call win_execute(winid, 'silent %delete _')
  call setbufline(bufnr, 1, a:lines)
  call ftx#core#buffer#SetModifiable(0)
endfunction

function! ftx#core#buffer#GetLines() abort
  let bufnr = ftx#core#buffer#Get()
  if bufnr == -1
    return []
  endif
  return getbufline(bufnr, 1, '$')
endfunction