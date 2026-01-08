" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

function! ftx#internal#commands#ftx#execute(mods, fargs) abort
  try
    let path = get(a:fargs, 0, getcwd())
    let path = fnamemodify(expand(path), ':p')
    
    if !isdirectory(path)
      throw 'Not a directory: ' . path
    endif
    if len(a:fargs) > 1 && a:fargs[1] ==# '-drawer'
      call ftx#internal#drawer#open({'focus': 1})
    endif
    call ftx#open(path)
  catch
    echohl ErrorMsg
    echom '[FTX] ' . v:exception
    echohl None
    call ftx#helpers#logger#error(v:exception, v:throwpoint)
  endtry
endfunction