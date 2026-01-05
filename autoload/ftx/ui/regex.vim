" Copyright (c) 2026 m-mdy-m
" MIT License

function! ftx#ui#regex#Escape(str) abort
  if empty(a:str)
    return ''
  endif
  return escape(a:str, '\^\$\.\*\+\?\(\)\[\]\{\}\|')
endfunction

function! ftx#ui#regex#BuildIconPattern(icon) abort
  if empty(a:icon)
    return ''
  endif

  let escaped = escape(a:icon, '\\')
  return '\V^\s*\zs' . escaped . '\ze\s'
endfunction

function! ftx#ui#regex#BuildGitPattern(icon) abort
  if empty(a:icon)
    return ''
  endif
  
  let escaped = ftx#ui#regex#Escape(a:icon)
  return '\v' . escaped . '\s\ze'
endfunction

function! ftx#ui#regex#GetAllPatterns() abort
  let patterns = {}
  
  if !empty(g:ftx_icon_expanded)
    let patterns.expanded = ftx#ui#regex#BuildIconPattern(g:ftx_icon_expanded)
  endif
  
  if !empty(g:ftx_icon_collapsed)
    let patterns.collapsed = ftx#ui#regex#BuildIconPattern(g:ftx_icon_collapsed)
  endif
  
  if !empty(g:ftx_icon_file)
    let patterns.file = ftx#ui#regex#BuildIconPattern(g:ftx_icon_file)
  endif
  
  if !empty(g:ftx_icon_symlink)
    let patterns.symlink = ftx#ui#regex#BuildIconPattern(g:ftx_icon_symlink)
  endif
  
  if g:ftx_enable_marks && !empty(g:ftx_icon_marked)
    let patterns.marked = ftx#ui#regex#BuildGitPattern(g:ftx_icon_marked)
  endif
  
  if g:ftx_enable_git && g:ftx_git_status
    if !empty(g:ftx_git_icon_added)
      let patterns.git_added = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_added)
    endif
    
    if !empty(g:ftx_git_icon_modified)
      let patterns.git_modified = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_modified)
    endif
    
    if !empty(g:ftx_git_icon_deleted)
      let patterns.git_deleted = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_deleted)
    endif
    
    if !empty(g:ftx_git_icon_renamed)
      let patterns.git_renamed = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_renamed)
    endif
    
    if !empty(g:ftx_git_icon_untracked)
      let patterns.git_untracked = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_untracked)
    endif
    
    if !empty(g:ftx_git_icon_ignored)
      let patterns.git_ignored = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_ignored)
    endif
    
    if !empty(g:ftx_git_icon_unmerged)
      let patterns.git_unmerged = ftx#ui#regex#BuildGitPattern(g:ftx_git_icon_unmerged)
    endif
  endif
  
  let patterns.indent = '\v^\s+'
  let patterns.hidden = '\v\.\f+'
  
  return patterns
endfunction