" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Buffer content replacement
" ----------------------------------------------------------------------

function! ftx#internal#replacer#replace(bufnr, content) abort
  if !bufexists(a:bufnr)
    throw 'Buffer does not exist: ' . a:bufnr
  endif
  
  let modified_saved = getbufvar(a:bufnr, '&modified')
  let modifiable_saved = getbufvar(a:bufnr, '&modifiable')
  
  try
    call setbufvar(a:bufnr, '&modifiable', 1)
    call s:replace_lines(a:bufnr, a:content)
  finally
    call setbufvar(a:bufnr, '&modifiable', modifiable_saved)
    call setbufvar(a:bufnr, '&modified', modified_saved)
  endtry
endfunction

function! s:replace_lines(bufnr, content) abort
  let line_count = len(a:content)
  
  if line_count == 0
    call deletebufline(a:bufnr, 1, '$')
    call setbufline(a:bufnr, 1, '')
    return
  endif
  
  call setbufline(a:bufnr, 1, a:content)
  
  let current_count = len(getbufline(a:bufnr, 1, '$'))
  if current_count > line_count
    call deletebufline(a:bufnr, line_count + 1, '$')
  endif
endfunction

function! ftx#internal#replacer#append(bufnr, content) abort
  if !bufexists(a:bufnr)
    throw 'Buffer does not exist: ' . a:bufnr
  endif
  
  let modified_saved = getbufvar(a:bufnr, '&modified')
  let modifiable_saved = getbufvar(a:bufnr, '&modifiable')
  
  try
    call setbufvar(a:bufnr, '&modifiable', 1)
    let last_line = len(getbufline(a:bufnr, 1, '$'))
    call appendbufline(a:bufnr, last_line, a:content)
  finally
    call setbufvar(a:bufnr, '&modifiable', modifiable_saved)
    call setbufvar(a:bufnr, '&modified', modified_saved)
  endtry
endfunction

function! ftx#internal#replacer#clear(bufnr) abort
  call ftx#internal#replacer#replace(a:bufnr, [])
endfunction