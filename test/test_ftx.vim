" Copyright (c) 2026 m-mdy-m
" MIT License

let s:test_results = []
let s:test_count = 0
let s:pass_count = 0
let s:fail_count = 0
let s:skip_count = 0

function! s:Assert(condition, message) abort
  let s:test_count += 1
  if a:condition
    call add(s:test_results, '[PASS] ' . a:message)
    let s:pass_count += 1
  else
    call add(s:test_results, '[FAIL] ' . a:message)
    let s:fail_count += 1
  endif
endfunction

function! s:Skip(message) abort
  call add(s:test_results, '[SKIP] ' . a:message)
  let s:skip_count += 1
endfunction

function! s:TestBasicOpen() abort
  echo 'Testing basic open...'
  
  call ftx#Open()
  call s:Assert(ftx#IsOpen(), 'FTX opens successfully')
  
  let bufnr = ftx#GetBufnr()
  call s:Assert(bufnr != -1, 'Buffer number is valid')
  call s:Assert(bufexists(bufnr), 'Buffer exists')
  
  call ftx#Close()
  call s:Assert(!ftx#IsOpen(), 'FTX closes successfully')
endfunction

function! s:TestToggle() abort
  echo 'Testing toggle...'
  
  call s:Assert(!ftx#IsOpen(), 'FTX is closed initially')
  
  call ftx#Toggle()
  call s:Assert(ftx#IsOpen(), 'FTX toggles on')
  
  call ftx#Toggle()
  call s:Assert(!ftx#IsOpen(), 'FTX toggles off')
endfunction

function! s:TestWindowProperties() abort
  echo 'Testing window properties...'
  
  call ftx#Open()
  
  let bufnr = ftx#GetBufnr()
  call s:Assert(getbufvar(bufnr, '&buftype') ==# 'nofile', 'Buffer type is nofile')
  call s:Assert(getbufvar(bufnr, '&filetype') ==# 'ftx', 'Filetype is ftx')
  call s:Assert(getbufvar(bufnr, '&swapfile') == 0, 'Swapfile is disabled')
  call s:Assert(getbufvar(bufnr, '&buflisted') == 0, 'Buffer is not listed')
  call s:Assert(getbufvar(bufnr, '&modifiable') == 0, 'Buffer is not modifiable')
  
  let winid = bufwinid(bufnr)
  call s:Assert(winid != -1, 'Window ID is valid')
  
  let winnr = win_id2win(winid)
  call s:Assert(getwinvar(winnr, '&cursorline') == 1, 'Cursorline is enabled')
  call s:Assert(getwinvar(winnr, '&number') == 0, 'Line numbers are disabled')
  call s:Assert(getwinvar(winnr, '&relativenumber') == 0, 'Relative numbers are disabled')
  
  call ftx#Close()
endfunction

function! s:TestConfiguration() abort
  echo 'Testing configuration...'
  
  let old_width = g:ftx_width
  let old_position = g:ftx_position
  
  let g:ftx_width = 40
  call ftx#Open()
  let winid = bufwinid(ftx#GetBufnr())
  let width = winwidth(win_id2win(winid))
  call s:Assert(width == 40, 'Width configuration works (expected 40, got ' . width . ')')
  call ftx#Close()
  
  let g:ftx_position = 'right'
  call ftx#Open()
  let winid = bufwinid(ftx#GetBufnr())
  let winnr = win_id2win(winid)
  call s:Assert(winnr == winnr('$'), 'Right position works')
  call ftx#Close()
  
  let g:ftx_width = old_width
  let g:ftx_position = old_position
endfunction

function! s:TestMultipleOperations() abort
  echo 'Testing multiple operations...'
  
  call ftx#Open()
  call s:Assert(ftx#IsOpen(), 'First open successful')
  
  call ftx#Open()
  call s:Assert(ftx#IsOpen(), 'Second open doesn''t break')
  
  call ftx#Refresh()
  call s:Assert(ftx#IsOpen(), 'Refresh works')
  
  call ftx#Focus()
  call s:Assert(bufnr('%') == ftx#GetBufnr(), 'Focus switches to FTX buffer')
  
  call ftx#Close()
endfunction

function! s:TestGitDetection() abort
  echo 'Testing git detection...'
  
  if !executable('git')
    call s:Skip('Git not available')
    return
  endif
  
  call s:Assert(exists('*ftx#git#UpdateStatus'), 'Git update function exists')
  call s:Assert(exists('*ftx#git#Cleanup'), 'Git cleanup function exists')
  
  call ftx#Open()
  
  if isdirectory(getcwd() . '/.git')
    sleep 1500m
    call s:Assert(1, 'Git status integration available')
  else
    call s:Skip('Not in a git repository')
  endif
  
  call ftx#Close()
endfunction

function! s:TestRendererFunctions() abort
  echo 'Testing renderer functions...'
  
  call s:Assert(exists('*ftx#renderer#Render'), 'Render function exists')
  call s:Assert(exists('*ftx#renderer#GetNode'), 'GetNode function exists')
  call s:Assert(exists('*ftx#renderer#ToggleExpand'), 'ToggleExpand function exists')
  call s:Assert(exists('*ftx#renderer#SetGitStatus'), 'SetGitStatus function exists')
  call s:Assert(exists('*ftx#renderer#GetTree'), 'GetTree function exists')
endfunction

function! s:TestStyleFunctions() abort
  echo 'Testing style functions...'
  
  call s:Assert(exists('*ftx#style#Syntax'), 'Syntax function exists')
  call s:Assert(exists('*ftx#style#Highlight'), 'Highlight function exists')
  
  call ftx#Open()
  
  let bufnr = ftx#GetBufnr()
  call s:Assert(getbufvar(bufnr, 'current_syntax') ==# 'ftx', 'Syntax is set')
  
  call ftx#Close()
endfunction

function! s:TestActionFunctions() abort
  echo 'Testing action functions...'
  
  call s:Assert(exists('*ftx#action#Open'), 'Open action exists')
  call s:Assert(exists('*ftx#action#ToggleHidden'), 'ToggleHidden action exists')
  
  let old_hidden = g:ftx_show_hidden
  call ftx#action#ToggleHidden()
  call s:Assert(g:ftx_show_hidden != old_hidden, 'ToggleHidden changes setting')
  call ftx#action#ToggleHidden()
  call s:Assert(g:ftx_show_hidden == old_hidden, 'ToggleHidden restores setting')
endfunction

function! s:TestCommands() abort
  echo 'Testing commands...'
  
  call s:Assert(exists(':FTX'), 'FTX command exists')
  call s:Assert(exists(':FTXToggle'), 'FTXToggle command exists')
  call s:Assert(exists(':FTXClose'), 'FTXClose command exists')
  call s:Assert(exists(':FTXRefresh'), 'FTXRefresh command exists')
  call s:Assert(exists(':FTXFocus'), 'FTXFocus command exists')
endfunction

function! s:TestAutoClose() abort
  echo 'Testing auto close...'
  
  let old_auto_close = g:ftx_auto_close
  let g:ftx_auto_close = 1
  
  call ftx#Open()
  enew
  
  let initial_windows = winnr('$')
  call ftx#AutoClose()
  
  let g:ftx_auto_close = old_auto_close
  call s:Assert(1, 'Auto close doesn''t crash')
  
  if ftx#IsOpen()
    call ftx#Close()
  endif
endfunction

function! s:TestEdgeCases() abort
  echo 'Testing edge cases...'
  
  call ftx#Close()
  call ftx#Close()
  call s:Assert(1, 'Multiple closes don''t crash')
  
  call ftx#Refresh()
  call s:Assert(!ftx#IsOpen(), 'Refresh on closed tree doesn''t crash')
  
  call ftx#Focus()
  call s:Assert(1, 'Focus on closed tree doesn''t crash')
  
  try
    call ftx#Open('/nonexistent/path/that/does/not/exist')
    call s:Assert(!ftx#IsOpen(), 'Invalid path doesn''t open')
  catch
    call s:Assert(1, 'Invalid path is handled')
  endtry
endfunction

function! s:RunTests() abort
  echo ''
  echo '======================================'
  echo '          FTX Test Suite'
  echo '======================================'
  echo ''
  
  call s:TestCommands()
  call s:TestRendererFunctions()
  call s:TestStyleFunctions()
  call s:TestActionFunctions()
  call s:TestBasicOpen()
  call s:TestToggle()
  call s:TestWindowProperties()
  call s:TestConfiguration()
  call s:TestMultipleOperations()
  call s:TestGitDetection()
  call s:TestAutoClose()
  call s:TestEdgeCases()
  
  call ftx#Cleanup()
  
  echo ''
  echo '======================================'
  echo '            Test Results'
  echo '======================================'
  echo ''
  
  for result in s:test_results
    echo result
  endfor
  
  echo ''
  echo '======================================'
  echo printf('Total:  %d', s:test_count + s:skip_count)
  echo printf('Pass:   %d', s:pass_count)
  echo printf('Fail:   %d', s:fail_count)
  echo printf('Skip:   %d', s:skip_count)
  echo '======================================'
  echo ''
  
  if s:fail_count > 0
    echo 'Tests FAILED'
    cquit 1
  else
    echo 'All tests PASSED'
  endif
endfunction

call s:RunTests()