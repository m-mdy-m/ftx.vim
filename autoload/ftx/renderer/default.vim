" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Default renderer with sync rendering
" ----------------------------------------------------------------------

let s:ESCAPE_PATTERN = '^$~.*[]\'

function! ftx#renderer#default#new() abort
  return {
        \ 'render': funcref('s:render'),
        \ 'syntax': funcref('s:syntax'),
        \ 'highlight': funcref('s:highlight'),
        \}
endfunction

function! s:render(nodes) abort
  let lines = []
  
  for node in a:nodes
    call add(lines, s:render_node(node))
  endfor
  
  return ftx#async#promise#resolve(lines)
endfunction

function! s:render_node(node) abort
  let parts = []
  
  if a:node.depth > 0
    call add(parts, repeat('  ', a:node.depth))
  endif
  
  call add(parts, s:get_icon(a:node))
  
  if get(g:, 'ftx_enable_marks', 1) && ftx#tree#marks#is_marked(a:node.path)
    call add(parts, get(g:, 'ftx_icon_marked', '✓') . ' ')
  endif
  
  if get(g:, 'ftx_enable_git', 1) && has_key(a:node, 'git_status') && !empty(a:node.git_status)
    call add(parts, a:node.git_status . ' ')
  endif
  
  call add(parts, a:node.name)
  
  if a:node.is_dir
    call add(parts, '/')
  endif
  
  return join(parts, '')
endfunction

function! s:get_icon(node) abort
  if a:node.depth == 0
    return get(g:, 'ftx_icon_root', '')
  endif
  
  if a:node.is_dir
    return get(a:node, 'is_expanded', 0)
          \ ? get(g:, 'ftx_icon_expanded', '▾') . ' '
          \ : get(g:, 'ftx_icon_collapsed', '▸') . ' '
  endif
  
  if get(a:node, 'is_link', 0)
    return get(g:, 'ftx_icon_symlink', '→') . ' '
  endif
  
  return get(g:, 'ftx_icon_file', ' ') . ' '
endfunction

function! s:syntax() abort
  syntax clear
  
  syntax match FTXIndent /^\s\+/ contained
  syntax match FTXDir /^.*\/$/
  syntax match FTXFile /^.*[^/]$/
  
  let expanded = escape(get(g:, 'ftx_icon_expanded', '▾'), s:ESCAPE_PATTERN)
  let collapsed = escape(get(g:, 'ftx_icon_collapsed', '▸'), s:ESCAPE_PATTERN)
  let file_icon = escape(get(g:, 'ftx_icon_file', ' '), s:ESCAPE_PATTERN)
  
  if !empty(expanded)
    execute 'syntax match FTXIconExpanded /' . expanded . '/ contained'
  endif
  
  if !empty(collapsed)
    execute 'syntax match FTXIconCollapsed /' . collapsed . '/ contained'
  endif
  
  if !empty(file_icon)
    execute 'syntax match FTXIconFile /' . file_icon . '/ contained'
  endif
  
  if get(g:, 'ftx_enable_marks', 1)
    let mark_icon = escape(get(g:, 'ftx_icon_marked', '✓'), s:ESCAPE_PATTERN)
    if !empty(mark_icon)
      execute 'syntax match FTXMark /' . mark_icon . '/ contained'
    endif
  endif
  
  if get(g:, 'ftx_enable_git', 1)
    call s:syntax_git()
  endif
endfunction

function! s:syntax_git() abort
  let icons = {
        \ 'added': get(g:, 'ftx_git_icon_added', '+'),
        \ 'modified': get(g:, 'ftx_git_icon_modified', '*'),
        \ 'deleted': get(g:, 'ftx_git_icon_deleted', '-'),
        \ 'renamed': get(g:, 'ftx_git_icon_renamed', '→'),
        \ 'untracked': get(g:, 'ftx_git_icon_untracked', '?'),
        \ 'ignored': get(g:, 'ftx_git_icon_ignored', '◌'),
        \ 'unmerged': get(g:, 'ftx_git_icon_unmerged', '!'),
        \}
  
  for [name, icon] in items(icons)
    if !empty(icon)
      let escaped = escape(icon, s:ESCAPE_PATTERN)
      let group = 'FTXGit' . toupper(name[0]) . name[1:]
      execute 'syntax match ' . group . ' /' . escaped . '/ contained'
    endif
  endfor
endfunction

function! s:highlight() abort
  highlight default link FTXDir Directory
  highlight default link FTXFile Normal
  highlight default link FTXIndent Comment
  
  highlight default FTXIconExpanded ctermfg=75 guifg=#5fafd7
  highlight default FTXIconCollapsed ctermfg=75 guifg=#5fafd7
  highlight default FTXIconFile ctermfg=245 guifg=#8a8a8a
  
  if get(g:, 'ftx_enable_marks', 1)
    highlight default FTXMark ctermfg=214 guifg=#ffaf00 gui=bold cterm=bold
  endif
  
  if get(g:, 'ftx_enable_git', 1)
    highlight default FTXGitAdded ctermfg=113 guifg=#87d75f gui=bold cterm=bold
    highlight default FTXGitModified ctermfg=221 guifg=#ffd787 gui=bold cterm=bold
    highlight default FTXGitDeleted ctermfg=203 guifg=#ff5f5f gui=bold cterm=bold
    highlight default FTXGitRenamed ctermfg=141 guifg=#af87ff
    highlight default FTXGitUntracked ctermfg=245 guifg=#8a8a8a
    highlight default FTXGitIgnored ctermfg=238 guifg=#444444 gui=italic cterm=italic
    highlight default FTXGitUnmerged ctermfg=197 guifg=#ff005f gui=bold cterm=bold
  endif
endfunction