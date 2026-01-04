" Copyright (c) 2026 m-mdy-m
" MIT License

function! ftx#ui#style#Syntax() abort
  syntax match ftxIndent /^\s\+/ contained
  
  let expanded = escape(g:ftx_icon_expanded, '\^$.*~[]')
  let collapsed = escape(g:ftx_icon_collapsed, '\^$.*~[]')
  let file = escape(g:ftx_icon_file, '\^$.*~[]')
  let symlink = escape(g:ftx_icon_symlink, '\^$.*~[]')
  let marked = escape(g:ftx_icon_marked, '\^$.*~[]')
  
  if !empty(expanded)
    execute 'syntax match ftxDirExpanded /' . expanded . '/ contained'
  endif
  if !empty(collapsed)
    execute 'syntax match ftxDirCollapsed /' . collapsed . '/ contained'
  endif
  if !empty(file)
    execute 'syntax match ftxFileIcon /' . file . '/ contained'
  endif
  if !empty(symlink)
    execute 'syntax match ftxSymlink /' . symlink . '/ contained'
  endif
  
  if g:ftx_enable_marks && !empty(marked)
    execute 'syntax match ftxMarked /' . marked . '/ contained'
  endif
  
  if g:ftx_enable_git && g:ftx_git_status
    let git_added = escape(g:ftx_git_icon_added, '\^$.*~[]')
    let git_modified = escape(g:ftx_git_icon_modified, '\^$.*~[]')
    let git_deleted = escape(g:ftx_git_icon_deleted, '\^$.*~[]')
    let git_renamed = escape(g:ftx_git_icon_renamed, '\^$.*~[]')
    let git_untracked = escape(g:ftx_git_icon_untracked, '\^$.*~[]')
    let git_ignored = escape(g:ftx_git_icon_ignored, '\^$.*~[]')
    let git_unmerged = escape(g:ftx_git_icon_unmerged, '\^$.*~[]')
    
    if !empty(git_added)
      execute 'syntax match ftxGitStaged /' . git_added . '/ contained'
    endif
    if !empty(git_modified)
      execute 'syntax match ftxGitModified /' . git_modified . '/ contained'
    endif
    if !empty(git_deleted)
      execute 'syntax match ftxGitDeleted /' . git_deleted . '/ contained'
    endif
    if !empty(git_renamed)
      execute 'syntax match ftxGitRenamed /' . git_renamed . '/ contained'
    endif
    if !empty(git_untracked)
      execute 'syntax match ftxGitUntracked /' . git_untracked . '/ contained'
    endif
    if !empty(git_ignored)
      execute 'syntax match ftxGitIgnored /' . git_ignored . '/ contained'
    endif
    if !empty(git_unmerged)
      execute 'syntax match ftxGitConflict /' . git_unmerged . '/ contained'
    endif
  endif
  
  syntax match ftxHidden /\.\w\+/ contained
  
  syntax match ftxDir /[^/]\+\/$/ contains=ftxDirExpanded,ftxDirCollapsed,ftxMarked,ftxGitStaged,ftxGitModified,ftxGitDeleted,ftxGitUntracked,ftxGitIgnored,ftxGitConflict,ftxGitRenamed
  
  syntax match ftxFile /[^/]\+$/ contains=ftxFileIcon,ftxSymlink,ftxMarked,ftxGitStaged,ftxGitModified,ftxGitDeleted,ftxGitUntracked,ftxGitIgnored,ftxGitConflict,ftxGitRenamed,ftxHidden
  " 
  syntax cluster ftxAll contains=ftxDir,ftxFile,ftxDirExpanded,ftxDirCollapsed,ftxFileIcon,ftxSymlink,ftxMarked,ftxGitStaged,ftxGitModified,ftxGitDeleted,ftxGitUntracked,ftxGitIgnored,ftxGitConflict,ftxGitRenamed,ftxHidden
endfunction

function! ftx#ui#style#Highlight() abort
    highlight default FTXDir ctermfg=75 guifg=#5fafd7 gui=bold cterm=bold
    highlight default FTXFile ctermfg=252 guifg=#d0d0d0
    highlight default FTXHidden ctermfg=243 guifg=#767676 gui=italic cterm=italic
    highlight default FTXSourceCode ctermfg=185 guifg=#d7d75f
    highlight default FTXDirExpanded ctermfg=75 guifg=#5fafd7
    highlight default FTXDirCollapsed ctermfg=75 guifg=#5fafd7
    highlight default FTXFileIcon ctermfg=245 guifg=#8a8a8a
    highlight default FTXSymlink ctermfg=51 guifg=#00ffff gui=italic cterm=italic
    highlight default FTXMarked ctermfg=214 guifg=#ffaf00 gui=bold cterm=bold
    highlight default FTXGitStaged ctermfg=113 guifg=#87d75f gui=bold cterm=bold
    highlight default FTXGitModified ctermfg=221 guifg=#ffd787 gui=bold cterm=bold
    highlight default FTXGitDeleted ctermfg=203 guifg=#ff5f5f gui=bold cterm=bold
    highlight default FTXGitRenamed ctermfg=141 guifg=#af87ff
    highlight default FTXGitUntracked ctermfg=245 guifg=#8a8a8a
    highlight default FTXGitIgnored ctermfg=238 guifg=#444444 gui=italic cterm=italic
    highlight default FTXGitConflict ctermfg=197 guifg=#ff005f gui=bold cterm=bold
    highlight default FTXBorder ctermfg=240 guifg=#585858
endfunction