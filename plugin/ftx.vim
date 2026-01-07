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
  echo '[FTX] Requires Vim 8.0+ with +job and +timers'
  echohl None
  finish
endif

let g:ftx_width = get(g:, 'ftx_width', 30)
let g:ftx_position = get(g:, 'ftx_position', 'left')
let g:ftx_show_hidden = get(g:, 'ftx_show_hidden', 1)
let g:ftx_sort_dirs_first = get(g:, 'ftx_sort_dirs_first', 1)
let g:ftx_auto_close = get(g:, 'ftx_auto_close', 0)
let g:ftx_auto_sync = get(g:, 'ftx_auto_sync', 1)
let g:ftx_close_on_open = get(g:, 'ftx_close_on_open', 0)
let g:ftx_enable_icons = get(g:, 'ftx_enable_icons', 1)
let g:ftx_icon_root = get(g:, 'ftx_icon_root', '')
let g:ftx_icon_expanded = get(g:, 'ftx_icon_expanded', '▾')
let g:ftx_icon_collapsed = get(g:, 'ftx_icon_collapsed', '▸')
let g:ftx_icon_file = get(g:, 'ftx_icon_file', '')
let g:ftx_icon_symlink = get(g:, 'ftx_icon_symlink', '→')
let g:ftx_enable_marks = get(g:, 'ftx_enable_marks', 1)
let g:ftx_icon_marked = get(g:, 'ftx_icon_marked', '✓')
let g:ftx_enable_git = get(g:, 'ftx_enable_git', 1)
let g:ftx_git_status = get(g:, 'ftx_git_status', 1)
let g:ftx_git_update_time = get(g:, 'ftx_git_update_time', 1000)
let g:ftx_git_blame = get(g:, 'ftx_git_blame', 0)
let g:ftx_show_ignored = get(g:, 'ftx_show_ignored', 0)
let g:ftx_git_icon_added = get(g:, 'ftx_git_icon_added', '+')
let g:ftx_git_icon_modified = get(g:, 'ftx_git_icon_modified', '*')
let g:ftx_git_icon_deleted = get(g:, 'ftx_git_icon_deleted', '-')
let g:ftx_git_icon_renamed = get(g:, 'ftx_git_icon_renamed', '→')
let g:ftx_git_icon_untracked = get(g:, 'ftx_git_icon_untracked', '?')
let g:ftx_git_icon_ignored = get(g:, 'ftx_git_icon_ignored', '◌')
let g:ftx_git_icon_unmerged = get(g:, 'ftx_git_icon_unmerged', '!')
let g:ftx_icons = get(g:, 'ftx_icons', {})
let g:ftx_special_icons = get(g:, 'ftx_special_icons', {})
let g:ftx_colors = get(g:, 'ftx_colors', {})
command! -nargs=? -complete=customlist,ftx#internal#commands#ftx#complete FTX
      \ call ftx#internal#commands#ftx#execute(<q-mods>, [<f-args>])

command! FTXToggle call ftx#toggle()
command! FTXClose call ftx#close()
command! FTXRefresh call ftx#refresh()
command! FTXFocus call ftx#focus()
command! FTXToggleHidden call ftx#mapping#tree#toggle_hidden()
command! FTXExpandAll call ftx#mapping#tree#expand_all()
command! FTXCollapseAll call ftx#mapping#tree#collapse_all()
command! FTXGoParent call ftx#mapping#tree#go_parent()
command! FTXGoHome call ftx#mapping#tree#go_home()
if get(g:, 'ftx_enable_git', 1)
  command! FTXRefreshGit call ftx#git#status#refresh()
  command! FTXBranchInfo call ftx#git#branch#show_info()
  
  if get(g:, 'ftx_git_blame', 0)
    command! FTXBlame call ftx#git#blame#show()
  endif
endif
if get(g:, 'ftx_enable_marks', 1)
  command! FTXMarkToggle call ftx#mapping#mark#toggle()
  command! FTXMarkClear call ftx#mapping#mark#clear()
  command! FTXMarkedOpen call ftx#mapping#mark#open_all()
  
  if get(g:, 'ftx_enable_git', 1)
    command! FTXMarkStageAll call ftx#mapping#mark#stage_all()
  endif
endif
command! FTXYankAbsolute call ftx#mapping#yank#absolute()
command! FTXYankRelative call ftx#mapping#yank#relative()
command! FTXYankName call ftx#mapping#yank#name()
command! FTXCd call ftx#mapping#node#cd()
command! FTXHelp call ftx#mapping#tree#show_help()
nnoremap <silent> <F2> :<C-u>FTXToggle<CR>
nnoremap <silent> <F3> :<C-u>FTXRefresh<CR>
nnoremap <silent> <leader>n :<C-u>FTXToggle<CR>
nnoremap <silent> <leader>nf :<C-u>FTXFocus<CR>
nnoremap <silent> <leader>nr :<C-u>FTXRefresh<CR>
nnoremap <silent> <leader>nh :<C-u>FTXHelp<CR>

augroup ftx_global
  autocmd!
  
  autocmd VimEnter *
        \ if argc() == 1 && isdirectory(argv()[0]) |
        \   execute 'cd' fnameescape(argv()[0]) |
        \   call ftx#open() |
        \ endif
  if get(g:, 'ftx_auto_close', 0)
    autocmd BufEnter *
          \ if winnr('$') == 1 && ftx#is_open() |
          \   quit |
          \ endif
  endif
  autocmd VimLeave * call ftx#cleanup()
augroup END
call ftx#async#internal#state#init()