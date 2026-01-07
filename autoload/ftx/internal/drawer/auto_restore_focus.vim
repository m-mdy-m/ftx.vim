" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Auto-restore focus when closing windows
" ----------------------------------------------------------------------

let s:info = v:null

function! ftx#internal#drawer#auto_restore_focus#init() abort
  if get(g:, 'ftx_disable_auto_restore_focus', 0)
    return
  endif
  
  augroup ftx_drawer_auto_restore_focus_local
    autocmd! * <buffer>
    autocmd WinLeave <buffer> call s:on_leave()
  augroup END
endfunction

function! s:on_leave() abort
  let s:info = {
        \ 'nwin': s:count_windows(),
        \ 'tabpage': tabpagenr(),
        \ 'prev': win_getid(winnr('#')),
        \}
  call timer_start(0, {-> extend(s:, {'info': v:null})})
endfunction

function! s:auto_restore() abort
  if s:info is v:null
    return
  endif
  
  if s:info.tabpage == tabpagenr() && s:info.nwin > s:count_windows()
    call win_gotoid(s:info.prev)
  endif
  
  let s:info = v:null
endfunction

function! s:count_windows() abort
  if has('nvim')
    try
      let num = 0
      for winnr in range(1, winnr('$'))
        if nvim_win_get_config(win_getid(winnr)).relative ==# ''
          let num += 1
        endif
      endfor
      return num
    catch
      return winnr('$')
    endtry
  else
    return winnr('$')
  endif
endfunction

augroup ftx_drawer_auto_restore_focus_global
  autocmd!
  autocmd WinEnter * nested call s:auto_restore()
augroup END