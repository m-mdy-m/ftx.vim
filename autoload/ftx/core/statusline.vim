" Copyright (c) 2026 m-mdy-m
" MIT License
" Statusline management

function! ftx#core#statusline#Update(root) abort
  let bufnr = ftx#core#buffer#Get()
  if bufnr == -1
    return
  endif
  
  let status = s:BuildStatus(a:root)
  call setbufvar(bufnr, '&statusline', status)
endfunction

function! s:BuildStatus(root) abort
  let parts = []
  
  " Directory name
  call add(parts, s:GetDirName(a:root))
  
  " Git info
  if g:ftx_enable_git && g:ftx_show_branch_info
    let git_info = s:GetGitInfo()
    if !empty(git_info)
      call add(parts, git_info)
    endif
  endif
  
  " Marked count
  if g:ftx_enable_marks
    let marked = ftx#features#marks#Count()
    if marked > 0
      call add(parts, '[' . marked . ' marked]')
    endif
  endif
  
  return ' ' . join(parts, ' ')
endfunction

function! s:GetDirName(root) abort
  let name = ftx#utils#GetBasename(a:root)
  return empty(name) ? '/' : name
endfunction

function! s:GetGitInfo() abort
  let info = ftx#git#branch#GetInfo()
  if empty(info)
    return ''
  endif
  
  let parts = []
  
  let branch = get(info, 'branch', '')
  if !empty(branch)
    call add(parts, '[' . branch . ']')
  endif
  
  if get(info, 'ahead', 0) > 0
    call add(parts, '↑' . info.ahead)
  endif
  
  if get(info, 'behind', 0) > 0
    call add(parts, '↓' . info.behind)
  endif
  
  if get(info, 'has_stash', 0)
    call add(parts, '$')
  endif
  
  return join(parts, ' ')
endfunction