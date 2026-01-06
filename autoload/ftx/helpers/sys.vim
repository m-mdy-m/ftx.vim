" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#helpers#sys#shellescape(str) abort
  return shellescape(a:str)
endfunction

function! ftx#helpers#sys#glob(pattern, ...) abort
  let nosuf = get(a:, 1, 1)
  let list = get(a:, 2, 1)
  let alllinks = get(a:, 3, 0)
  return glob(a:pattern, nosuf, list, alllinks)
endfunction

function! ftx#helpers#sys#readdir(path) abort
  if !isdirectory(a:path)
    return []
  endif
  
  let items = []
  let regular = ftx#helpers#sys#glob(a:path . '/*', 1, 1)
  
  for item in regular
    call add(items, item)
  endfor
  
  if get(g:, 'ftx_show_hidden', 0)
    let hidden = ftx#helpers#sys#glob(a:path . '/.[^.]*', 1, 1)
    for item in hidden
      call add(items, item)
    endfor
  endif
  
  return items
endfunction

function! ftx#helpers#sys#readdir_names(path) abort
  let items = ftx#helpers#sys#readdir(a:path)
  return map(items, 'ftx#helpers#path#basename(v:val)')
endfunction

function! ftx#helpers#sys#getftype(path) abort
  return getftype(a:path)
endfunction