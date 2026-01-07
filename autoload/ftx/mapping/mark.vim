" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" ----------------------------------------------------------------------

function! ftx#mapping#mark#toggle() abort
  if !get(g:, 'ftx_enable_marks', 1)
    call ftx#helpers#logger#error('Marking is disabled')
    return
  endif
  
  let node = ftx#tree#ui#get_cursor_node()
  
  if empty(node)
    return
  endif
  
  let was_marked = ftx#tree#marks#is_marked(node.path)
  
  if was_marked
    call ftx#tree#marks#unmark(node.path)
    call ftx#helpers#logger#info('Unmarked: ' . node.name)
  else
    call ftx#tree#marks#mark(node.path, node)
    call ftx#helpers#logger#info('Marked: ' . node.name)
  endif
  
  call ftx#refresh()
endfunction

function! ftx#mapping#mark#clear() abort
  let count = ftx#tree#marks#count()
  call ftx#tree#marks#clear()
  call ftx#refresh()
  call ftx#helpers#logger#info('Cleared ' . count . ' marks')
endfunction

function! ftx#mapping#mark#open_all() abort
  let marks = ftx#tree#marks#get_all()
  
  if empty(marks)
    call ftx#helpers#logger#error('No marked files')
    return
  endif
  
  let files = s:get_marked_files(marks)
  
  if empty(files)
    call ftx#helpers#logger#error('No valid files marked')
    return
  endif
  
  call s:open_files(files)
  call ftx#tree#marks#clear()
  call ftx#refresh()
  
  call ftx#helpers#logger#info('Opened ' . len(files) . ' files')
endfunction

function! s:get_marked_files(marks) abort
  let files = []
  
  for [path, node] in items(a:marks)
    if !node.is_dir && ftx#helpers#path#is_readable(path)
      call add(files, path)
    endif
  endfor
  
  return files
endfunction

function! s:open_files(files) abort
  let target_win = s:find_target_window()
  
  if target_win != -1
    execute target_win . 'wincmd w'
  else
    wincmd p
  endif
  
  execute 'edit ' . fnameescape(a:files[0])
  
  for file in a:files[1:]
    execute 'tabedit ' . fnameescape(file)
  endfor
endfunction

function! s:find_target_window() abort
  let ftx_bufnr = ftx#internal#buffer#get()
  
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

function! ftx#mapping#mark#stage_all() abort
  if !get(g:, 'ftx_enable_git', 1) || !executable('git')
    call ftx#helpers#logger#error('Git not available')
    return
  endif
  
  let marks = ftx#tree#marks#get_all()
  
  if empty(marks)
    call ftx#helpers#logger#error('No marked files')
    return
  endif
  
  let files = s:get_marked_files(marks)
  
  if empty(files)
    call ftx#helpers#logger#error('No valid files marked')
    return
  endif
  
  call s:stage_files_async(files)
        \.then({count -> s:on_stage_complete(count)})
        \.catch({err -> ftx#helpers#logger#error('Stage failed', err)})
endfunction

function! s:stage_files_async(files) abort
  let root = ftx#tree#tree#get_root()
  let promises = []
  
  for file in a:files
    let cmd = ['git', '-C', root, 'add', file]
    call add(promises, ftx#async#job#run(cmd))
  endfor
  
  return ftx#async#promise#all(promises)
        \.then({_ -> len(a:files)})
endfunction

function! s:on_stage_complete(count) abort
  call ftx#tree#marks#clear()
  call ftx#refresh()
  call ftx#helpers#logger#info('Staged ' . a:count . ' files')
endfunction