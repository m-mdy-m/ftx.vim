" Copyright (c) 2026 m-mdy-m
" MIT License

function! ftx#action#Open(cmd) abort
  let node = ftx#renderer#GetNode()
  
  if empty(node)
    return
  endif
  
  if node.is_dir
    call ftx#renderer#ToggleExpand(node)
    return
  endif
  
  if !filereadable(node.path)
    echohl ErrorMsg
    echo '[FTX] File not readable: ' . node.path
    echohl None
    return
  endif
  
  let suitable_win = s:FindSuitableWindow()
  
  if suitable_win != -1
    execute suitable_win . 'wincmd w'
  else
    wincmd p
  endif
  
  execute a:cmd . ' ' . fnameescape(node.path)
  
  if get(g:, 'ftx_close_on_open', 0)
    call ftx#Close()
  endif
endfunction

function! ftx#action#ToggleHidden() abort
  let g:ftx_show_hidden = !g:ftx_show_hidden
  call ftx#Refresh()
  
  echo '[FTX] Hidden files: ' . (g:ftx_show_hidden ? 'shown' : 'hidden')
endfunction

function! ftx#action#RefreshGit() abort
  if !g:ftx_git_status
    echo '[FTX] Git integration is disabled'
    return
  endif
  
  echo '[FTX] Refreshing git status...'
  call ftx#git#Refresh()
endfunction

function! ftx#action#GoUp() abort
  let root = ftx#GetRoot()
  let parent = fnamemodify(root, ':h')
  
  if parent !=# root && isdirectory(parent)
    call ftx#Open(parent)
  else
    echo '[FTX] Already at root'
  endif
endfunction

function! ftx#action#GoHome() abort
  let home = expand('~')
  if isdirectory(home)
    call ftx#Open(home)
  endif
endfunction

function! s:FindSuitableWindow() abort
  let ftx_bufnr = ftx#GetBufnr()
  
  for winnr in range(1, winnr('$'))
    let bufnr = winbufnr(winnr)
    
    if bufnr == ftx_bufnr
      continue
    endif
    
    if getbufvar(bufnr, '&buftype') ==# ''
      return winnr
    endif
  endfor
  
  return -1
endfunction