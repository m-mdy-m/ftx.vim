" Copyright (c) 2026 m-mdy-m
" MIT License

function! ftx#ui#style#Syntax() abort
  if exists('b:current_syntax')
    unlet b:current_syntax
  endif
  syntax clear
  
  let p = ftx#ui#regex#GetAllPatterns()
  
  syntax match FTXIndent /\v^\s+/ contained
  syntax match FTXHidden /\v\.\f+/ contained
  
  if has_key(p, 'expanded') && !empty(p.expanded)
    execute 'syntax match FTXDirExpanded /' . p.expanded . '/ contained'
  endif
  
  if has_key(p, 'collapsed') && !empty(p.collapsed)
    execute 'syntax match FTXDirCollapsed /' . p.collapsed . '/ contained'
  endif
  
  if has_key(p, 'file') && !empty(p.file)
    execute 'syntax match FTXFileIcon /' . p.file . '/ contained'
  endif
  
  if has_key(p, 'symlink') && !empty(p.symlink)
    execute 'syntax match FTXSymlink /' . p.symlink . '/ contained'
  endif
  
  if g:ftx_enable_marks && has_key(p, 'marked') && !empty(p.marked)
    execute 'syntax match FTXMarked /' . p.marked . '/ contained'
  endif
  
  if g:ftx_enable_git && g:ftx_git_status
    if has_key(p, 'git_added') && !empty(p.git_added)
      execute 'syntax match FTXGitStaged /' . p.git_added . '/ contained'
    endif
    if has_key(p, 'git_modified') && !empty(p.git_modified)
      execute 'syntax match FTXGitModified /' . p.git_modified . '/ contained'
    endif
    if has_key(p, 'git_deleted') && !empty(p.git_deleted)
      execute 'syntax match FTXGitDeleted /' . p.git_deleted . '/ contained'
    endif
    if has_key(p, 'git_renamed') && !empty(p.git_renamed)
      execute 'syntax match FTXGitRenamed /' . p.git_renamed . '/ contained'
    endif
    if has_key(p, 'git_untracked') && !empty(p.git_untracked)
      execute 'syntax match FTXGitUntracked /' . p.git_untracked . '/ contained'
    endif
    if has_key(p, 'git_ignored') && !empty(p.git_ignored)
      execute 'syntax match FTXGitIgnored /' . p.git_ignored . '/ contained'
    endif
    if has_key(p, 'git_unmerged') && !empty(p.git_unmerged)
      execute 'syntax match FTXGitConflict /' . p.git_unmerged . '/ contained'
    endif
  endif
  
  syntax match FTXDir /\v^.*$/ 
        \ contains=FTXIndent,FTXDirExpanded,FTXDirCollapsed,FTXMarked,
        \FTXGitStaged,FTXGitModified,FTXGitDeleted,FTXGitRenamed,
        \FTXGitUntracked,FTXGitIgnored,FTXGitConflict
  
  syntax match FTXFile /\v^.*$/ 
        \ contains=FTXIndent,FTXFileIcon,FTXSymlink,FTXMarked,FTXHidden,
        \FTXGitStaged,FTXGitModified,FTXGitDeleted,FTXGitRenamed,
        \FTXGitUntracked,FTXGitIgnored,FTXGitConflict
  
  call s:ApplyFileTypeColors()
  
  let b:current_syntax = 'ftx'
endfunction

function! s:ApplyFileTypeColors() abort
  let colors = get(g:, 'ftx_colors', {})
  
  for [ext, color_spec] in items(colors)
    let group_name = 'FTXFile_' . substitute(ext, '[^a-zA-Z0-9]', '_', 'g')
    execute 'syntax match ' . group_name . ' /\v^.*\.' . ext . '$/ containedin=FTXFile'
    execute 'highlight ' . group_name . ' ' . color_spec
  endfor
endfunction

function! ftx#ui#style#Highlight() abort
  highlight default FTXDir ctermfg=75 guifg=#5FAFD7 gui=bold cterm=bold
  highlight default FTXFile ctermfg=252 guifg=#D0D0D0
  highlight default FTXIndent ctermfg=237 guifg=#3A3A3A
  highlight default FTXHidden ctermfg=243 guifg=#767676 gui=italic cterm=italic
  highlight default FTXDirExpanded ctermfg=75 guifg=#5FAFD7 gui=bold cterm=bold
  highlight default FTXDirCollapsed ctermfg=75 guifg=#5FAFD7 gui=bold cterm=bold
  highlight default FTXFileIcon ctermfg=245 guifg=#8A8A8A
  highlight default FTXSymlink ctermfg=51 guifg=#00FFFF gui=italic cterm=italic
  highlight default FTXMarked ctermfg=214 guifg=#FFAF00 gui=bold cterm=bold
  highlight default FTXGitStaged ctermfg=113 guifg=#87D75F gui=bold cterm=bold
  highlight default FTXGitModified ctermfg=221 guifg=#FFD787 gui=bold cterm=bold
  highlight default FTXGitDeleted ctermfg=203 guifg=#FF5F5F gui=bold cterm=bold
  highlight default FTXGitRenamed ctermfg=141 guifg=#AF87FF
  highlight default FTXGitUntracked ctermfg=245 guifg=#8A8A8A
  highlight default FTXGitIgnored ctermfg=238 guifg=#444444 gui=italic cterm=italic
  highlight default FTXGitConflict ctermfg=197 guifg=#FF005F gui=bold cterm=bold
  highlight default FTXBorder ctermfg=240 guifg=#585858
endfunction

function! ftx#ui#style#Apply() abort
  call ftx#ui#style#Syntax()
  call ftx#ui#style#Highlight()
endfunction