" Copyright (c) 2025 m-mdy-m
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.

if exists('g:loaded_ftx')
  finish
endif
let g:loaded_ftx = 1
if !has('job') || !has('timers')
  echohl ErrorMsg
  echo '[ftx] Vim 8.0+ with +job and +timers is required'
  echohl None
  finish
endif

let g:ftx_width = get(g:, 'ftx_width', 30)
let g:ftx_position = get(g:, 'ftx_position', 'left')
let g:ftx_show_hidden = get(g:, 'ftx_show_hidden', 0)
let g:ftx_git_status = get(g:, 'ftx_git_status', 1)
let g:ftx_sort_dirs_first = get(g:, 'ftx_sort_dirs_first', 1)
let g:ftx_auto_close = get(g:, 'ftx_auto_close', 0)
let g:ftx_git_update_time = get(g:, 'ftx_git_update_time', 1000)
command! -nargs=? -complete=dir FTX call ftx#Open(<q-args>)
command! FTXToggle call ftx#Toggle()
command! FTXClose call ftx#Close()
command! FTXRefresh call ftx#Refresh()
command! FTXFocus call ftx#Focus()
nnoremap <silent> <F2> :FTX<CR>

augroup ftx_internal
  autocmd!
  autocmd BufEnter * call ftx#AutoClose()
  autocmd VimLeave * call ftx#Cleanup()
augroup END