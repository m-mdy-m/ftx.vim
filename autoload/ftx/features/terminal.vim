" Copyright (c) 2026 m-mdy-m
" MIT License
" Terminal integration

function! ftx#features#terminal#Open() abort
  if !has('terminal')
    call ftx#utils#EchoError('Terminal feature not available')
    return
  endif
  
  let path = s:GetTargetPath()
  if !ftx#utils#IsDirectory(path)
    call ftx#utils#EchoError('Invalid directory: ' . path)
    return
  endif
  
  call s:OpenTerminalInPath(path)
  call ftx#utils#EchoSuccess('Opened terminal in: ' . fnamemodify(path, ':~'))
endfunction

function! s:GetTargetPath() abort
  let node = ftx#ui#renderer#GetNode()
  
  if empty(node)
    return ftx#GetRoot()
  endif
  
  return node.is_dir ? node.path : ftx#utils#GetParentDir(node.path)
endfunction

function! s:OpenTerminalInPath(path) abort
  let suitable_win = ftx#utils#FindSuitableWindow()
  
  if suitable_win != -1
    execute suitable_win . 'wincmd w'
  else
    wincmd p
    botright split
  endif
  
  execute 'lcd ' . fnameescape(a:path)
  
  if has('nvim')
    terminal
  else
    terminal ++curwin
  endif
endfunction