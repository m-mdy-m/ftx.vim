" Copyright (c) 2026 m-mdy-m
" MIT License

let s:bufnr = -1
let s:root = ''
let s:bufname_counter = 0

function! ftx#Open(...) abort
  let path = a:0 > 0 ? fnamemodify(a:1, ':p') : getcwd()
  
  if !isdirectory(path)
    echohl ErrorMsg
    echo '[FTX] Not a directory: ' . path
    echohl None
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
  
  if g:ftx_git_status
    call timer_start(100, {-> ftx#git#UpdateStatus(s:root)})
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
  
  let winid = bufwinid(s:bufnr)
  if winid != -1
    execute win_id2win(winid) . 'close'
  endif
  
  let s:bufnr = -1
endfunction

function! ftx#Refresh() abort
  if !ftx#IsOpen()
    return
  endif
  
  let save_line = line('.')
  let save_col = col('.')
  
  call ftx#renderer#Render(s:root)
  
  call cursor(save_line, save_col)
  call s:UpdateStatusLine()
endfunction

function! ftx#Focus() abort
  if !ftx#IsOpen()
    return
  endif
  
  let winid = bufwinid(s:bufnr)
  if winid != -1
    call win_gotoid(winid)
  endif
endfunction

function! ftx#IsOpen() abort
  return s:bufnr != -1 && bufexists(s:bufnr)
endfunction

function! ftx#AutoClose() abort
  if !g:ftx_auto_close || !ftx#IsOpen()
    return
  endif
  
  let wincount = winnr('$')
  if wincount == 1 && bufnr('%') == s:bufnr
    quit
  endif
endfunction

function! ftx#Cleanup() abort
  call ftx#git#Cleanup()
endfunction

function! ftx#GetRoot() abort
  return s:root
endfunction

function! ftx#GetBufnr() abort
  return s:bufnr
endfunction

function! s:CreateWindow() abort
  let pos = g:ftx_position ==# 'right' ? 'botright' : 'topleft'
  execute pos . ' ' . g:ftx_width . 'vnew'
  
  let s:bufnr = bufnr('%')
  let s:bufname_counter += 1
  
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal nonumber
  setlocal norelativenumber
  setlocal signcolumn=no
  setlocal foldcolumn=0
  setlocal nomodeline
  setlocal nofoldenable
  setlocal cursorline
  setlocal filetype=ftx
  
  execute 'silent! file FTX_' . s:bufname_counter
  
  call s:SetupMappings()
  call s:UpdateStatusLine()
endfunction

function! s:UpdateStatusLine() abort
  if !ftx#IsOpen()
    return
  endif
  
  let bufnr = ftx#GetBufnr()
  let dir_name = fnamemodify(s:root, ':t')
  if dir_name ==# ''
    let dir_name = '/'
  endif
  
  let git_info = ftx#git#GetBranchInfo()
  let status = ' ' . dir_name
  
  if !empty(git_info)
    let branch = get(git_info, 'branch', '')
    if branch !=# ''
      let status .= ' [' . branch . ']'
    endif
    
    if get(git_info, 'ahead', 0) > 0
      let status .= ' ↑' . git_info.ahead
    endif
    if get(git_info, 'behind', 0) > 0
      let status .= ' ↓' . git_info.behind
    endif
    if get(git_info, 'has_stash', 0)
      let status .= ' $'
    endif
  endif
  
  call setbufvar(bufnr, '&statusline', status)
endfunction

function! s:SetupMappings() abort
  nnoremap <buffer> <silent> o :call ftx#action#Open('edit')<CR>
  nnoremap <buffer> <silent> <CR> :call ftx#action#Open('edit')<CR>
  nnoremap <buffer> <silent> t :call ftx#action#Open('tabedit')<CR>
  nnoremap <buffer> <silent> s :call ftx#action#Open('split')<CR>
  nnoremap <buffer> <silent> v :call ftx#action#Open('vsplit')<CR>
  nnoremap <buffer> <silent> r :call ftx#Refresh()<CR>
  nnoremap <buffer> <silent> R :call ftx#action#RefreshGit()<CR>
  nnoremap <buffer> <silent> I :call ftx#action#ToggleHidden()<CR>
  nnoremap <buffer> <silent> q :call ftx#Close()<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> :call ftx#action#Open('edit')<CR>
  nnoremap <buffer> <silent> - :call ftx#action#GoUp()<CR>
  nnoremap <buffer> <silent> ~ :call ftx#action#GoHome()<CR>
endfunction

function! ftx#UpdateStatusLine() abort
  call s:UpdateStatusLine()
endfunction