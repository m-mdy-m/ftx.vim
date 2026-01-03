" Copyright (c) 2026 m-mdy-m
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
  echo '[FTX] Vim 8.0+ with +job and +timers is required'
  echohl None
  finish
endif

let g:ftx_width = get(g:, 'ftx_width', 30)
let g:ftx_position = get(g:, 'ftx_position', 'left')
let g:ftx_show_hidden = get(g:, 'ftx_show_hidden', 1)
let g:ftx_sort_dirs_first = get(g:, 'ftx_sort_dirs_first', 1)
let g:ftx_auto_close = get(g:, 'ftx_auto_close', 0)
let g:ftx_auto_sync = get(g:, 'ftx_auto_sync', 1)
let g:ftx_enable_git = get(g:, 'ftx_enable_git', 1)
let g:ftx_git_status = get(g:, 'ftx_git_status', 1)
let g:ftx_git_update_time = get(g:, 'ftx_git_update_time', 1000)
let g:ftx_git_blame = get(g:, 'ftx_git_blame', 0)
let g:ftx_show_branch_info = get(g:, 'ftx_show_branch_info', 1)
let g:ftx_branch_info_float = get(g:, 'ftx_branch_info_float', 1)
let g:ftx_show_ignored = get(g:, 'ftx_show_ignored', 0)
let g:ftx_enable_icons = get(g:, 'ftx_enable_icons', 1)
let g:ftx_icon_expanded = get(g:, 'ftx_icon_expanded', '▾')
let g:ftx_icon_collapsed = get(g:, 'ftx_icon_collapsed', '▸')
let g:ftx_icon_file = get(g:, 'ftx_icon_file', ' ')
let g:ftx_icon_symlink = get(g:, 'ftx_icon_symlink', '→')
let g:ftx_icon_marked = get(g:, 'ftx_icon_marked', '✓')
let g:ftx_git_icon_added = get(g:, 'ftx_git_icon_added', '+')
let g:ftx_git_icon_modified = get(g:, 'ftx_git_icon_modified', '*')
let g:ftx_git_icon_deleted = get(g:, 'ftx_git_icon_deleted', '-')
let g:ftx_git_icon_renamed = get(g:, 'ftx_git_icon_renamed', '→')
let g:ftx_git_icon_untracked = get(g:, 'ftx_git_icon_untracked', '?')
let g:ftx_git_icon_ignored = get(g:, 'ftx_git_icon_ignored', '◌')
let g:ftx_git_icon_unmerged = get(g:, 'ftx_git_icon_unmerged', '!')
let g:ftx_enable_marks = get(g:, 'ftx_enable_marks', 1)

augroup ftx_auto_open
  autocmd!
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) | 
        \ execute 'cd' fnameescape(argv()[0]) | 
        \ call ftx#Open() | 
        \ endif
augroup END

command! -nargs=? -complete=dir FTX call ftx#Open(<q-args>)
command! FTXToggle call ftx#Toggle()
command! FTXClose call ftx#Close()
command! FTXRefresh call ftx#Refresh()
command! FTXFocus call ftx#Focus()
command! FTXToggleHidden call ftx#actions#ToggleHidden()
command! FTXExpandAll call ftx#ui#renderer#ExpandAll() | call ftx#Refresh()
command! FTXCollapseAll call ftx#ui#renderer#CollapseAll() | call ftx#Refresh()
command! -nargs=1 FTXExpandToDepth call ftx#ui#renderer#ExpandToDepth(<args>) | call ftx#Refresh()
command! FTXMarkToggle call ftx#features#marks#Toggle()
command! FTXMarkClear call ftx#features#marks#Clear()
command! FTXMarkedOpen call ftx#features#marks#OpenAll()
command! FTXMarkedStage call ftx#features#marks#StageAll()
command! FTXOpenTerminal call ftx#features#terminal#Open()
command! FTXRefreshGit call ftx#actions#RefreshGit()
command! FTXBranchInfo call ftx#git#branch#ShowInfo()
command! FTXBlame call ftx#git#blame#Show()
command! FTXHelp call ftx#features#help#Show()
nnoremap <silent> <F2> :FTXToggle<CR>
nnoremap <silent> <F3> :FTXRefresh<CR>
nnoremap <silent> <leader>n :FTXToggle<CR>
nnoremap <silent> <leader>nf :FTXFocus<CR>
nnoremap <silent> <leader>nr :FTXRefresh<CR>
nnoremap <silent> <leader>nh :FTXHelp<CR>

augroup ftx_internal
  autocmd!
  autocmd BufEnter * call ftx#AutoClose()
  autocmd VimLeave * call ftx#Cleanup()
  
  if g:ftx_auto_sync
    autocmd BufEnter * call ftx#AutoSync()
  endif
  
  if g:ftx_enable_git && g:ftx_git_status
    autocmd BufWritePost * call ftx#actions#RefreshGit()
  endif
augroup END