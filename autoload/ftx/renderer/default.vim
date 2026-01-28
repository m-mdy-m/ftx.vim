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
    let icon = get(a:node, 'is_expanded', 0) 
          \ ? get(g:, 'ftx_icon_expanded', '▾') 
          \ : get(g:, 'ftx_icon_collapsed', '▸')
    if !empty(icon)
      call add(parts, icon . ' ')
    endif
  endif
  
  if get(g:, 'ftx_enable_git', 1)
    let status = ftx#git#status#get(a:node.path)
    if !empty(status) && status !~# '^  $'
      call add(parts, printf('[%s] ', status))
    endif
  endif
  
  if get(g:, 'ftx_enable_marks', 1) && ftx#tree#marks#is_marked(a:node.path)
    call add(parts, get(g:, 'ftx_icon_marked', '✓') . ' ')
  endif
  
  if get(g:, 'ftx_enable_icons', 1) && !a:node.is_dir
    let icon = s:get_file_icon(a:node)
    if !empty(icon)
      call add(parts, icon . ' ')
    endif
  endif
  
  call add(parts, a:node.name)
  
  if a:node.is_dir
    call add(parts, '/')
  endif
  
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
  syntax match FTXFile /\v[^\/]+$/

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

  if get(g:, 'ftx_enable_git', 1)
    syntax match FTXGitStatusBracket /\[\zs..\ze\]/ contained
    syntax match FTXGitStatus /\[..\]/ contains=FTXGitStatusBracket
    
    syntax match FTXGitStatusIndex /./ contained containedin=FTXGitStatusBracket nextgroup=FTXGitStatusWorktree
    syntax match FTXGitStatusWorktree /./ contained
    
    syntax match FTXGitStatusUnmerged /DD\|AU\|UD\|UA\|DU\|AA\|UU/ contained containedin=FTXGitStatusBracket
    syntax match FTXGitStatusUntracked /??/ contained containedin=FTXGitStatusBracket
    syntax match FTXGitStatusIgnored /!!/ contained containedin=FTXGitStatusBracket
  endif

  if get(g:, 'ftx_enable_marks', 1)
    let mark = get(g:, 'ftx_icon_marked', '✓')
    if !empty(mark)
      execute 'syntax match FTXMark /' . s:esc(mark) . '/'
    endif
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
  highlight! link FTXLine Normal
  highlight! link FTXIndent Comment
  highlight! FTXDir   ctermfg=81  guifg=#5fd7ff gui=bold cterm=bold
  highlight! FTXFile  ctermfg=240 guifg=#505050 gui=bold cterm=bold

  if get(g:, 'ftx_enable_icons', 1)
    highlight! FTXIconExpanded ctermfg=51 guifg=#00d7ff gui=bold cterm=bold
    highlight! FTXIconCollapsed ctermfg=51 guifg=#00d7ff gui=bold cterm=bold
  endif

  if get(g:, 'ftx_enable_git', 1)
    highlight! link FTXGitStatus Comment
    highlight! FTXGitStatusIndex     ctermfg=244 guifg=#808080
    highlight! FTXGitStatusWorktree  ctermfg=202 guifg=#ff5f00
    highlight! FTXGitStatusUnmerged  ctermfg=196 guifg=#ff0000 gui=bold cterm=bold
    highlight! FTXGitStatusUntracked ctermfg=244 guifg=#808080
    highlight! FTXGitStatusIgnored   ctermfg=238 guifg=#444444 gui=italic cterm=italic
    highlight! link FTXGitStatusBracket Comment
  endif

  if get(g:, 'ftx_enable_marks', 1)
    highlight! FTXMark ctermfg=220 guifg=#ffd75f gui=bold cterm=bold
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
      execute 'highlight! ' . group_icon . ' ctermfg=245 guifg=#8a8a8a'
      execute 'highlight! ' . group_file . ' ctermfg=245 guifg=#8a8a8a'
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
      execute 'highlight! ' . group_icon . ' ctermfg=245 guifg=#8a8a8a'
      execute 'highlight! ' . group_file . ' ctermfg=245 guifg=#8a8a8a'
    endif
  endfor
endfunction