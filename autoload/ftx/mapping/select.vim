" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Window selector - Visual window/tab selection inspired by fern.vim and
" vim-choosewin
" ----------------------------------------------------------------------

let s:selections = {}

function! ftx#mapping#select#open() abort
  let node = ftx#tree#ui#get_cursor_node()

  if empty(node)
    return
  endif

  if node.is_dir
    call ftx#mapping#tree#toggle_expand()
    return
  endif

  if !filereadable(node.path)
    call ftx#helpers#logger#error('File not readable', node.path)
    return
  endif

  let selected = s:select_window_visual()

  if selected.type ==# 'cancel'
    return
  endif

  call s:open_in_target(node.path, selected)

  if get(g:, 'ftx_close_on_open', 0)
    call ftx#close()
  endif
endfunction

function! s:select_window_visual() abort
  let saved_view = winsaveview()
  let saved_winid = win_getid()
  let windows = s:get_selectable_windows()

  if empty(windows)
    return {'type': 'new'}
  endif

  call s:show_overlay(windows)
  let result = s:wait_for_selection(windows)
  call s:hide_overlay(windows)

  call win_gotoid(saved_winid)
  call winrestview(saved_view)

  return result
endfunction

function! s:get_label_chars() abort
  let labels = split(get(g:, 'ftx_select_labels', 'asdfjklqweruiopzxcvbnm1234567890'), '\zs')
  return empty(labels) ? split('asdfjklqweruiopzxcvbnm1234567890', '\zs') : labels
endfunction

function! s:get_selectable_windows() abort
  let ftx_bufnr = ftx#internal#buffer#get()
  let windows = []
  let labels = s:get_label_chars()
  let label_idx = 0

  for winnr in range(1, winnr('$'))
    let winid = win_getid(winnr)
    let bufnr = winbufnr(winnr)

    if bufnr == ftx_bufnr
      continue
    endif

    if has('nvim')
      try
        let config = nvim_win_get_config(winid)
        if config.relative !=# ''
          continue
        endif
      catch
      endtry
    endif

    if label_idx >= len(labels)
      continue
    endif

    let label = labels[label_idx]
    call add(windows, {
          \ 'winnr': winnr,
          \ 'winid': winid,
          \ 'bufnr': bufnr,
          \ 'label': label,
          \ 'type': 'window',
          \ })
    let label_idx += 1
  endfor

  return windows
endfunction

function! s:show_overlay(windows) abort
  for win in a:windows
    let s:selections[win.label] = win

    if has('nvim')
      call s:nvim_show_label(win)
    else
      call s:vim_show_label(win)
    endif
  endfor

  call s:show_prompt(a:windows, '')
endfunction

function! s:show_prompt(windows, extra) abort
  redraw
  echohl FTXSelectorPrompt
  echo 'Select target [' . join(map(copy(a:windows), 'toupper(v:val.label)'), ' ') . '] '
        \ . '| <CR>/o: prev/new | t: tab | s: split | v: vsplit | q: cancel'
        \ . ' (labels have priority; use T/S/V/Q for commands)'
        \ . (empty(a:extra) ? '' : ' | ' . a:extra)
  echohl None
endfunction

function! s:nvim_show_label(win) abort
  if !exists('*nvim_win_get_width') || !exists('*nvim_win_get_height')
    return
  endif

  let badge = '  ' . toupper(a:win.label) . '  '
  let badge_width = strdisplaywidth(badge)
  let width = nvim_win_get_width(a:win.winid)
  let height = nvim_win_get_height(a:win.winid)

  if width <= 0 || height <= 0
    return
  endif

  let col = max([0, float2nr((width - badge_width) / 2.0)])
  let row = max([0, height - 1])

  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:true, [badge])

  let opts = {
        \ 'relative': 'win',
        \ 'win': a:win.winid,
        \ 'width': badge_width,
        \ 'height': 1,
        \ 'row': row,
        \ 'col': col,
        \ 'style': 'minimal',
        \ 'border': 'rounded',
        \ 'focusable': v:false,
        \ 'zindex': 100,
        \ }

  let winid = nvim_open_win(buf, v:false, opts)
  let a:win.overlay_winid = winid
  let a:win.overlay_bufnr = buf

  call nvim_win_set_option(winid, 'winhl', 'Normal:FTXSelectorLabel,FloatBorder:FTXSelectorLabelBorder')
endfunction

function! s:vim_show_label(win) abort
  if !has('popupwin')
    return
  endif

  let winnr = win_id2win(a:win.winid)
  if winnr <= 0
    return
  endif

  let pos = win_screenpos(winnr)
  let top = get(pos, 0, 1)
  let left = get(pos, 1, 1)
  let width = winwidth(winnr)
  let height = winheight(winnr)
  let badge = '  ' . toupper(a:win.label) . '  '
  let badge_width = strdisplaywidth(badge)
  let row = top + max([0, height - 1])
  let col = left + max([0, float2nr((width - badge_width) / 2.0)])

  let winid = popup_create(badge, {
        \ 'pos': 'topleft',
        \ 'line': row,
        \ 'col': col,
        \ 'minwidth': badge_width,
        \ 'minheight': 1,
        \ 'wrap': v:false,
        \ 'drag': v:false,
        \ 'border': [1, 1, 1, 1],
        \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'padding': [0, 0, 0, 0],
        \ 'zindex': 100,
        \ 'borderhighlight': ['FTXSelectorLabelBorder'],
        \ 'highlight': 'FTXSelectorLabel',
        \ })

  let a:win.overlay_winid = winid
endfunction

function! s:wait_for_selection(windows) abort
  let mapping = {}
  for win in a:windows
    let mapping[tolower(win.label)] = win
  endfor

  while 1
    let char = nr2char(getchar())
    let key = tolower(char)

    " Prioritize explicit window labels to avoid conflicts like label 's'
    if has_key(mapping, key)
      return extend(mapping[key], {'type': 'window'})
    endif

    if char ==# 'Q' || char ==# "\<Esc>"
      return {'type': 'cancel'}
    elseif char ==# 'T'
      return {'type': 'tab'}
    elseif char ==# 'S'
      return {'type': 'split'}
    elseif char ==# 'V'
      return {'type': 'vsplit'}
    elseif char ==# 'O' || char ==# "\<CR>"
      if ftx#internal#window#goto_previous()
        return {
              \ 'type': 'window',
              \ 'winid': win_getid(),
              \ }
      endif
      return {'type': 'new'}
    endif

    " Lowercase command aliases only when no label uses that key
    if !has_key(mapping, 'q') && key ==# 'q'
      return {'type': 'cancel'}
    elseif !has_key(mapping, 't') && key ==# 't'
      return {'type': 'tab'}
    elseif !has_key(mapping, 's') && key ==# 's'
      return {'type': 'split'}
    elseif !has_key(mapping, 'v') && key ==# 'v'
      return {'type': 'vsplit'}
    elseif !has_key(mapping, 'o') && key ==# 'o'
      if ftx#internal#window#goto_previous()
        return {
              \ 'type': 'window',
              \ 'winid': win_getid(),
              \ }
      endif
      return {'type': 'new'}
    endif

    call s:show_prompt(a:windows, 'Unknown key: ' . string(char))
  endwhile
endfunction

function! s:hide_overlay(windows) abort
  for win in a:windows
    if has('nvim')
      if has_key(win, 'overlay_winid')
        try
          call nvim_win_close(win.overlay_winid, v:true)
        catch
        endtry
      endif
      if has_key(win, 'overlay_bufnr')
        try
          call nvim_buf_delete(win.overlay_bufnr, {'force': v:true})
        catch
        endtry
      endif
    else
      if has_key(win, 'overlay_winid')
        try
          call popup_close(win.overlay_winid)
        catch
        endtry
      endif
    endif
  endfor

  let s:selections = {}
  redraw
endfunction

function! s:open_in_target(path, target) abort
  if a:target.type ==# 'cancel'
    return
  elseif a:target.type ==# 'tab'
    call s:open_in_new_tab(a:path)
  elseif a:target.type ==# 'split'
    call s:open_in_split(a:path, 0)
  elseif a:target.type ==# 'vsplit'
    call s:open_in_split(a:path, 1)
  elseif a:target.type ==# 'window'
    call s:open_in_window(a:path, a:target.winid)
  elseif a:target.type ==# 'new'
    call s:open_in_new_window(a:path)
  endif
endfunction

function! s:open_in_window(path, winid) abort
  call win_gotoid(a:winid)

  if &modified && !&hidden
    call s:open_in_new_tab(a:path)
    return
  endif

  execute 'edit ' . fnameescape(a:path)
endfunction

function! s:open_in_new_tab(path) abort
  execute 'tabedit ' . fnameescape(a:path)
endfunction

function! s:open_in_split(path, vertical) abort
  if ftx#internal#window#goto_previous()
    let cmd = a:vertical ? 'vsplit' : 'split'
  else
    let target_winid = ftx#internal#window#find_suitable()
    if target_winid != -1
      call win_gotoid(target_winid)
      let cmd = a:vertical ? 'vsplit' : 'split'
    else
      wincmd p
      let cmd = a:vertical ? 'vsplit' : 'split'
    endif
  endif

  execute cmd . ' ' . fnameescape(a:path)
endfunction

function! s:open_in_new_window(path) abort
  if ftx#internal#drawer#is_drawer()
    let position = get(g:, 'ftx_position', 'left')
    if position ==# 'left'
      wincmd l
    else
      wincmd h
    endif

    if &filetype ==# 'ftx'
      if position ==# 'left'
        botright vnew
      else
        topleft vnew
      endif
    endif
  else
    wincmd p
    if &filetype ==# 'ftx'
      botright new
    endif
  endif

  execute 'edit ' . fnameescape(a:path)
endfunction

function! s:setup_highlight() abort
  highlight default FTXSelectorLabel cterm=bold gui=bold ctermfg=231 ctermbg=31 guifg=#ffffff guibg=#0087af
  highlight default FTXSelectorLabelBorder cterm=bold gui=bold ctermfg=81 ctermbg=NONE guifg=#5fd7ff guibg=NONE
  highlight default link FTXSelectorPrompt MoreMsg
endfunction

call s:setup_highlight()

augroup ftx_selector
  autocmd!
  autocmd ColorScheme * call s:setup_highlight()
augroup END