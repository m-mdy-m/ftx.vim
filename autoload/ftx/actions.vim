" Copyright (c) 2026 m-mdy-m
" MIT License
" User actions

function! ftx#actions#Open(cmd) abort
  let node = ftx#ui#renderer#GetNode()
  if empty(node)
    return
  endif
  
  if node.is_dir
    call ftx#ui#renderer#ToggleExpand(node)
    call ftx#Refresh()
    return
  endif
  
  if !ftx#utils#IsReadable(node.path)
    call ftx#utils#EchoError('File not readable: ' . node.path)
    return
  endif
  
  call s:OpenInWindow(node.path, a:cmd)
  
  if get(g:, 'ftx_close_on_open', 0)
    call ftx#Close()
  endif
endfunction

function! s:OpenInWindow(path, cmd) abort
  let suitable_win = ftx#utils#FindSuitableWindow()
  
  if suitable_win != -1
    execute suitable_win . 'wincmd w'
  else
    wincmd p
  endif
  
  execute a:cmd . ' ' . fnameescape(a:path)
endfunction

function! ftx#actions#ToggleHidden() abort
  let g:ftx_show_hidden = !g:ftx_show_hidden
  call ftx#Refresh()
  call ftx#utils#EchoInfo('Hidden files: ' . (g:ftx_show_hidden ? 'shown' : 'hidden'))
endfunction

function! ftx#actions#RefreshGit() abort
  if !g:ftx_enable_git || !g:ftx_git_status
    call ftx#utils#EchoError('Git integration is disabled')
    return
  endif
  
  call ftx#utils#EchoInfo('Refreshing git status...')
  call ftx#git#status#Update(ftx#GetRoot())
endfunction

function! ftx#actions#GoUp() abort
  let root = ftx#GetRoot()
  let parent = ftx#utils#GetParentDir(root)
  
  if parent !=# root && ftx#utils#IsDirectory(parent)
    call ftx#Open(parent)
  else
    call ftx#utils#EchoInfo('Already at root')
  endif
endfunction

function! ftx#actions#GoHome() abort
  let home = expand('~')
  if ftx#utils#IsDirectory(home)
    call ftx#Open(home)
  endif
endfunction