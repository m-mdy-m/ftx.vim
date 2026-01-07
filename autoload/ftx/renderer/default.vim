" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
" ----------------------------------------------------------------------

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
  
  if get(g:, 'ftx_enable_icons', 1) && a:node.is_dir
    let icon = get(a:node, 'is_expanded', 0) ? get(g:, 'ftx_icon_expanded', '▾') : get(g:, 'ftx_icon_collapsed', '▸')
    if !empty(icon)
      call add(parts, icon . ' ')
    endif
  endif
  
  if get(g:, 'ftx_enable_marks', 1) && ftx#tree#marks#is_marked(a:node.path)
    call add(parts, get(g:, 'ftx_icon_marked', '✓') . ' ')
  endif
  
  if get(g:, 'ftx_enable_git', 1)
    let status = ftx#git#status#get(a:node.path)
    if !empty(status)
      call add(parts, status . ' ')
    endif
  endif
  
  if get(g:, 'ftx_enable_icons', 1) && !a:node.is_dir
    let icon = s:get_file_icon(a:node)
    if !empty(icon)
      call add(parts, icon . ' ')
    endif
  endif
  
  call add(parts, a:node.name)
  return join(parts, '')
endfunction

function! s:get_file_icon(node) abort
  if get(a:node, 'is_link', 0)
    return get(g:, 'ftx_icon_symlink', '→')
  endif
  
  let special = get(g:, 'ftx_special_icons', {})
  if has_key(special, a:node.name)
    return special[a:node.name]
  endif
  
  let ext = fnamemodify(a:node.name, ':e')
  if !empty(ext)
    let icons = get(g:, 'ftx_icons', {})
    if has_key(icons, ext)
      return icons[ext]
    endif
  endif
  
  return get(g:, 'ftx_icon_file', '')
endfunction

function! s:syntax() abort
  syntax clear
  syntax match FTXLine /^.*$/
  syntax match FTXIndent /^\s\+/
  if get(g:, 'ftx_enable_icons', 1)
    let exp = get(g:, 'ftx_icon_expanded', '▾')
    let col = get(g:, 'ftx_icon_collapsed', '▸')
    if !empty(exp)
      execute 'syntax match FTXIconExpanded /' . s:esc(exp) . '/'
    endif
    if !empty(col)
      execute 'syntax match FTXIconCollapsed /' . s:esc(col) . '/'
    endif
  endif
  if get(g:, 'ftx_enable_marks', 1)
    let mark = get(g:, 'ftx_icon_marked', '✓')
    if !empty(mark)
      execute 'syntax match FTXMark /' . s:esc(mark) . '/'
    endif
  endif
  
  if get(g:, 'ftx_enable_git', 1)
    let g:ftx_git_icon_added = get(g:, 'ftx_git_icon_added', '+')
    let g:ftx_git_icon_modified = get(g:, 'ftx_git_icon_modified', '*')
    let g:ftx_git_icon_deleted = get(g:, 'ftx_git_icon_deleted', '-')
    let g:ftx_git_icon_renamed = get(g:, 'ftx_git_icon_renamed', '→')
    let g:ftx_git_icon_untracked = get(g:, 'ftx_git_icon_untracked', '?')
    let g:ftx_git_icon_ignored = get(g:, 'ftx_git_icon_ignored', '◌')
    let g:ftx_git_icon_unmerged = get(g:, 'ftx_git_icon_unmerged', '!')
    
    execute 'syntax match FTXGitAdded /' . s:esc(g:ftx_git_icon_added) . '/'
    execute 'syntax match FTXGitModified /' . s:esc(g:ftx_git_icon_modified) . '/'
    execute 'syntax match FTXGitDeleted /' . s:esc(g:ftx_git_icon_deleted) . '/'
    execute 'syntax match FTXGitRenamed /' . s:esc(g:ftx_git_icon_renamed) . '/'
    execute 'syntax match FTXGitUntracked /' . s:esc(g:ftx_git_icon_untracked) . '/'
    execute 'syntax match FTXGitIgnored /' . s:esc(g:ftx_git_icon_ignored) . '/'
    execute 'syntax match FTXGitUnmerged /' . s:esc(g:ftx_git_icon_unmerged) . '/'
  endif
  
  let icons = get(g:, 'ftx_icons', {})
  for [ext, icon] in items(icons)
    if !empty(icon)
      execute 'syntax match FTXIcon' . toupper(ext) . ' /' . s:esc(icon) . '/'
      
      let pattern = '\v[^/\\]*\.' . ext . '$'
      execute 'syntax match FTXFile' . toupper(ext) . ' /' . pattern . '/'
    endif
  endfor
  
  let special = get(g:, 'ftx_special_icons', {})
  for [name, icon] in items(special)
    if !empty(icon)
      let clean = substitute(name, '[^a-zA-Z0-9]', '', 'g')
      
      execute 'syntax match FTXIconSpecial' . clean . ' /' . s:esc(icon) . '/'
      
      execute 'syntax match FTXFileSpecial' . clean . ' /\v' . s:esc(name) . '$/'
    endif
  endfor
  
  syntax match FTXDir /\/$/
endfunction

function! s:esc(text) abort
  let r = escape(a:text, '\^$.*[]~/')
  let r = substitute(r, '\[', '\\[', 'g')
  let r = substitute(r, '\]', '\\]', 'g')
  let r = substitute(r, '(', '\\(', 'g')
  let r = substitute(r, ')', '\\)', 'g')
  return r
endfunction

function! s:highlight() abort
  highlight default link FTXLine Normal
  highlight default link FTXIndent Comment
  highlight default FTXDir ctermfg=75 guifg=#5fafd7 gui=bold cterm=bold
  
  if get(g:, 'ftx_enable_icons', 1)
    highlight default FTXIconExpanded ctermfg=75 guifg=#5fafd7
    highlight default FTXIconCollapsed ctermfg=75 guifg=#5fafd7
  endif
  
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
  
  let colors = get(g:, 'ftx_colors', {})
  let icons = get(g:, 'ftx_icons', {})
  
  for [ext, icon] in items(icons)
    let group_icon = 'FTXIcon' . toupper(ext)
    let group_file = 'FTXFile' . toupper(ext)
    
    if has_key(colors, ext) && !empty(colors[ext])
      execute 'highlight! ' . group_icon . ' ' . colors[ext]
      execute 'highlight! ' . group_file . ' ' . colors[ext]
    else
      execute 'highlight default ' . group_icon . ' ctermfg=245 guifg=#8a8a8a'
      execute 'highlight default ' . group_file . ' ctermfg=245 guifg=#8a8a8a'
    endif
  endfor
  
  let special = get(g:, 'ftx_special_icons', {})
  for [name, icon] in items(special)
    let clean = substitute(name, '[^a-zA-Z0-9]', '', 'g')
    let group_icon = 'FTXIconSpecial' . clean
    let group_file = 'FTXFileSpecial' . clean
    let base = fnamemodify(name, ':r')
    
    if has_key(colors, name) && !empty(colors[name])
      execute 'highlight! ' . group_icon . ' ' . colors[name]
      execute 'highlight! ' . group_file . ' ' . colors[name]
    elseif has_key(colors, base) && !empty(colors[base])
      execute 'highlight! ' . group_icon . ' ' . colors[base]
      execute 'highlight! ' . group_file . ' ' . colors[base]
    else
      execute 'highlight default ' . group_icon . ' ctermfg=245 guifg=#8a8a8a'
      execute 'highlight default ' . group_file . ' ctermfg=245 guifg=#8a8a8a'
    endif
  endfor
endfunction