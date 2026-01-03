" Copyright (c) 2026 m-mdy-m
" MIT License
" Main FTX entry point

let s:root = ''
let s:last_sync_buf = -1

function! ftx#Open(...) abort
  let path = a:0 > 0 ? fnamemodify(a:1, ':p') : getcwd()
  
  if !ftx#utils#IsDirectory(path)
    call ftx#utils#EchoError('Not a directory: ' . path)
    return
  endif
  
  let s:root = path
  
  if ftx#IsOpen()
    call ftx#Focus()
    call ftx#Refresh()
    return
  endif
  
  call s:CreateWindow()
  call ftx#Refresh()
  
  if g:ftx_enable_git
    call ftx#git#status#Update(s:root)
  endif
endfunction

function! ftx#Toggle() abort
  if ftx#IsOpen()
    call ftx#Close()
  else
    call ftx#Open()
  endif
endfunction

function! ftx#Close() abort
  if !ftx#IsOpen()
    return
  endif
  
  call ftx#core#window#Close()
endfunction

function! ftx#Refresh() abort
  if !ftx#IsOpen()
    return
  endif
  
  call ftx#ui#renderer#Render(s:root)
  call ftx#UpdateStatusLine()
endfunction

function! ftx#Focus() abort
  if !ftx#IsOpen()
    return
  endif
  
  call ftx#core#window#Focus()
endfunction

function! ftx#IsOpen() abort
  return ftx#core#buffer#Exists() && ftx#core#buffer#IsVisible()
endfunction

function! ftx#GetRoot() abort
  return s:root
endfunction

function! ftx#GetBufnr() abort
  return ftx#core#buffer#Get()
endfunction

function! ftx#UpdateStatusLine() abort
  call ftx#core#statusline#Update(s:root)
endfunction

function! ftx#AutoClose() abort
  if !g:ftx_auto_close || !ftx#IsOpen()
    return
  endif
  
  if ftx#core#window#IsLast() && ftx#core#window#IsFTXWindow()
    quit
  endif
endfunction

function! ftx#AutoSync() abort
  if !g:ftx_auto_sync || !ftx#IsOpen()
    return
  endif
  
  let current_buf = bufnr('%')
  
  if current_buf == s:last_sync_buf || current_buf == ftx#GetBufnr()
    return
  endif
  
  let s:last_sync_buf = current_buf
  
  let file = expand('%:p')
  if empty(file) || !ftx#utils#IsReadable(file)
    return
  endif
  
  let file_dir = ftx#utils#GetParentDir(file)
  if file_dir =~# '^' . escape(s:root, '\')
    call ftx#ui#renderer#SyncToFile(file)
  endif
endfunction

function! ftx#Cleanup() abort
  call ftx#git#status#Cleanup()
  call ftx#git#branch#Cleanup()
  call ftx#git#blame#Cleanup()
  call ftx#features#marks#Clear()
endfunction

function! s:CreateWindow() abort
  call ftx#core#window#Create()
  call s:SetupMappings()
endfunction

function! s:SetupMappings() abort
  " Basic operations
  nnoremap <buffer> <silent> o  <Cmd>call ftx#actions#Open('edit')<CR>
  nnoremap <buffer> <silent> <CR> <Cmd>call ftx#actions#Open('edit')<CR>
  nnoremap <buffer> <silent> t  <Cmd>call ftx#actions#Open('tabedit')<CR>
  nnoremap <buffer> <silent> s  <Cmd>call ftx#actions#Open('split')<CR>
  nnoremap <buffer> <silent> v  <Cmd>call ftx#actions#Open('vsplit')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> <Cmd>call ftx#actions#Open('edit')<CR>
  
  " Navigation
  nnoremap <buffer> <silent> - :call ftx#actions#GoUp()<CR>
  nnoremap <buffer> <silent> ~ :call ftx#actions#GoHome()<CR>
  
  " Refresh & toggles
  nnoremap <buffer> <silent> r :call ftx#Refresh()<CR>
  nnoremap <buffer> <silent> R :call ftx#actions#RefreshGit()<CR>
  nnoremap <buffer> <silent> I :call ftx#actions#ToggleHidden()<CR>
  
  " Tree operations
  nnoremap <buffer> <silent> O :call ftx#ui#renderer#ExpandAll() \| call ftx#Refresh()<CR>
  nnoremap <buffer> <silent> C :call ftx#ui#renderer#CollapseAll() \| call ftx#Refresh()<CR>
  
  " Mark operations
  nnoremap <buffer> <silent> m :call ftx#features#marks#Toggle()<CR>
  nnoremap <buffer> <silent> M :call ftx#features#marks#Clear()<CR>
  nnoremap <buffer> <silent> mo :call ftx#features#marks#OpenAll()<CR>
  nnoremap <buffer> <silent> mg :call ftx#features#marks#StageAll()<CR>
  
  " File operations
  nnoremap <buffer> <silent> cd :call ftx#features#terminal#Open()<CR>
  
  " Git operations
  nnoremap <buffer> <silent> gb :call ftx#git#blame#Show()<CR>
  nnoremap <buffer> <silent> gi :call ftx#git#branch#ShowInfo()<CR>
  
  " Help & close
  nnoremap <buffer> <silent> ? :call ftx#features#help#Show()<CR>
  nnoremap <buffer> <silent> q :call ftx#Close()<CR>
endfunction