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

function! ftx#internal#commands#ftx#complete(arglead, cmdline, cursorpos) abort
  let candidates = []
  let matches = glob(a:arglead . '*', 0, 1)
  for match in matches
    if isdirectory(match)
      call add(candidates, match . '/')
    endif
  endfor
  let parts = split(a:cmdline, '\s\+')
  if len(parts) <= 2
    call add(candidates, '-drawer')
  endif
  return filter(candidates, 'v:val =~# "^" . escape(a:arglead, "\\[]*^$.")')
endfunction