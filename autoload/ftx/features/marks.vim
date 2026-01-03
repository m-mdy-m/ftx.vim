" Copyright (c) 2026 m-mdy-m
" MIT License
" Multi-file marking system

let s:marked = {}

function! ftx#features#marks#Toggle() abort
  if !g:ftx_enable_marks
    call ftx#utils#EchoError('Marking is disabled')
    return
  endif
  
  let node = ftx#ui#renderer#GetNode()
  if empty(node)
    return
  endif
  
  if ftx#features#marks#IsMarked(node.path)
    call ftx#features#marks#Unmark(node.path)
    call ftx#utils#EchoInfo('Unmarked: ' . node.name)
  else
    call ftx#features#marks#Mark(node.path, node)
    call ftx#utils#EchoInfo('Marked: ' . node.name)
  endif
  
  call ftx#Refresh()
endfunction

function! ftx#features#marks#Mark(path, node) abort
  let s:marked[a:path] = a:node
endfunction

function! ftx#features#marks#Unmark(path) abort
  if has_key(s:marked, a:path)
    unlet s:marked[a:path]
  endif
endfunction

function! ftx#features#marks#IsMarked(path) abort
  return has_key(s:marked, a:path)
endfunction

function! ftx#features#marks#Count() abort
  return len(s:marked)
endfunction

function! ftx#features#marks#Clear() abort
  let l:count = ftx#features#marks#Count()
  let s:marked = {}
  call ftx#Refresh()
  call ftx#utils#EchoInfo('Cleared ' . l:count . ' marks')
endfunction

function! ftx#features#marks#OpenAll() abort
  if empty(s:marked)
    call ftx#utils#EchoError('No marked files')
    return
  endif
  
  let files = s:GetMarkedFiles()
  if empty(files)
    call ftx#utils#EchoError('No valid files marked')
    return
  endif
  
  call s:OpenFiles(files)
  call ftx#utils#EchoSuccess('Opened ' . len(files) . ' files')
  call ftx#features#marks#Clear()
endfunction

function! ftx#features#marks#StageAll() abort
  if !g:ftx_enable_git || !executable('git')
    call ftx#utils#EchoError('Git not available')
    return
  endif
  
  if empty(s:marked)
    call ftx#utils#EchoError('No marked files')
    return
  endif
  
  let files = s:GetMarkedFiles()
  if empty(files)
    call ftx#utils#EchoError('No valid files marked')
    return
  endif
  
  call s:StageFiles(files)
  call ftx#features#marks#Clear()
endfunction

function! s:GetMarkedFiles() abort
  let files = []
  for [path, node] in items(s:marked)
    if !node.is_dir && ftx#utils#IsReadable(path)
      call add(files, path)
    endif
  endfor
  return files
endfunction

function! s:OpenFiles(files) abort
  let suitable_win = ftx#utils#FindSuitableWindow()
  if suitable_win != -1
    execute suitable_win . 'wincmd w'
  else
    wincmd p
  endif
  
  execute 'edit ' . fnameescape(a:files[0])
  
  for i in range(1, len(a:files) - 1)
    execute 'tabedit ' . fnameescape(a:files[i])
  endfor
endfunction

function! s:StageFiles(files) abort
  let root = ftx#git#status#GetRoot()
  if empty(root)
    call ftx#utils#EchoError('Not in a git repository')
    return
  endif
  
  let l:count = 0
  for file in a:files
    let cmd = 'git -C ' . shellescape(root) . ' add ' . shellescape(file)
    if system(cmd) == '' && v:shell_error == 0
      let l:count += 1
    endif
  endfor
  
  call ftx#utils#EchoSuccess('Staged ' . l:count . ' files')
  call ftx#git#status#Update(root)
endfunction