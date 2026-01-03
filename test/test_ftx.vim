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

function! s:CleanupFTX() abort
  if ftx#IsOpen()
    call ftx#Close()
  endif
  call ftx#Cleanup()
endfunction

function! s:TestCommands() abort
  echo 'Testing commands...'
  
  call s:Assert(exists(':FTX'), 'FTX command exists')
  call s:Assert(exists(':FTXOpen'), 'FTXOpen command exists')
  call s:Assert(exists(':FTXToggle'), 'FTXToggle command exists')
  call s:Assert(exists(':FTXClose'), 'FTXClose command exists')
  call s:Assert(exists(':FTXRefresh'), 'FTXRefresh command exists')
  call s:Assert(exists(':FTXRefreshGit'), 'FTXRefreshGit command exists')
  call s:Assert(exists(':FTXFocus'), 'FTXFocus command exists')
  call s:Assert(exists(':FTXToggleHidden'), 'FTXToggleHidden command exists')
endfunction

function! s:TestBasicOpen() abort
  echo 'Testing basic open...'
  
  call s:CleanupFTX()
  
  call ftx#Open()
  sleep 100m
  
  call s:Assert(ftx#IsOpen(), 'FTX opens successfully')
  
  let bufnr = ftx#GetBufnr()
  call s:Assert(bufnr != -1, 'Buffer number is valid')
  call s:Assert(bufexists(bufnr), 'Buffer exists')
  
  call s:CleanupFTX()
  call s:Assert(!ftx#IsOpen(), 'FTX closes successfully')
endfunction

function! s:TestToggle() abort
  echo 'Testing toggle...'
  
  call s:CleanupFTX()
  
  call s:Assert(!ftx#IsOpen(), 'FTX is closed initially')
  
  call ftx#Toggle()
  sleep 100m
  call s:Assert(ftx#IsOpen(), 'FTX toggles on')
  
  call ftx#Toggle()
  sleep 100m
  call s:Assert(!ftx#IsOpen(), 'FTX toggles off')
endfunction

function! s:TestWindowProperties() abort
  echo 'Testing window properties...'
  
  call s:CleanupFTX()
  call ftx#Open()
  sleep 100m
  
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
  
  call s:CleanupFTX()
endfunction

function! s:TestConfiguration() abort
  echo 'Testing configuration...'
  
  let old_width = g:ftx_width
  let old_position = g:ftx_position
  
  let g:ftx_width = 40
  call s:CleanupFTX()
  call ftx#Open()
  sleep 100m
  
  let winid = bufwinid(ftx#GetBufnr())
  let width = winwidth(win_id2win(winid))
  call s:Assert(width == 40, 'Width configuration works (expected 40, got ' . width . ')')
  
  call s:CleanupFTX()
  
  let g:ftx_position = 'right'
  call ftx#Open()
  sleep 100m
  
  let winid = bufwinid(ftx#GetBufnr())
  let winnr = win_id2win(winid)
  call s:Assert(winnr == winnr('$'), 'Right position works')
  
  call s:CleanupFTX()
  
  let g:ftx_width = old_width
  let g:ftx_position = old_position
endfunction

function! s:TestNavigation() abort
  echo 'Testing navigation...'
  
  call s:CleanupFTX()
  call ftx#Open()
  sleep 100m
  
  call s:Assert(ftx#IsOpen(), 'FTX is open for navigation test')
  
  call ftx#Focus()
  sleep 100m
  call s:Assert(bufnr('%') == ftx#GetBufnr(), 'Focus switches to FTX buffer')
  
  call ftx#Refresh()
  sleep 100m
  call s:Assert(ftx#IsOpen(), 'Refresh works')
  
  call s:CleanupFTX()
endfunction

function! s:TestHiddenFiles() abort
  echo 'Testing hidden files...'
  
  let old_hidden = g:ftx_show_hidden
  
  let g:ftx_show_hidden = 0
  call s:CleanupFTX()
  call ftx#Open()
  sleep 100m
  call s:Assert(g:ftx_show_hidden == 0, 'Hidden files initially hidden')
  
  call ftx#action#ToggleHidden()
  sleep 100m
  call s:Assert(g:ftx_show_hidden == 1, 'Hidden files toggled on')
  
  call ftx#action#ToggleHidden()
  sleep 100m
  call s:Assert(g:ftx_show_hidden == 0, 'Hidden files toggled off')
  
  call s:CleanupFTX()
  let g:ftx_show_hidden = old_hidden
endfunction

function! s:TestGitIntegration() abort
  echo 'Testing git integration...'
  
  if !executable('git')
    call s:Skip('Git not available')
    return
  endif
  
  if !isdirectory(getcwd() . '/.git')
    call s:Skip('Not in a git repository')
    return
  endif
  
  call s:Assert(exists('*ftx#git#UpdateStatus'), 'Git update function exists')
  call s:Assert(exists('*ftx#git#Cleanup'), 'Git cleanup function exists')
  call s:Assert(exists('*ftx#git#Refresh'), 'Git refresh function exists')
  call s:Assert(exists('*ftx#git#GetBranchInfo'), 'Git branch info function exists')
  
  let old_git_status = g:ftx_git_status
  let g:ftx_git_status = 1
  
  call s:CleanupFTX()
  call ftx#Open()
  sleep 500m
  
  call s:Assert(ftx#IsOpen(), 'FTX opens with git integration')
  
  call s:CleanupFTX()
  let g:ftx_git_status = old_git_status
endfunction

function! s:TestEdgeCases() abort
  echo 'Testing edge cases...'
  
  call s:CleanupFTX()
  call ftx#Close()
  call ftx#Close()
  call s:Assert(1, 'Multiple closes don''t crash')
  
  call ftx#Refresh()
  call s:Assert(!ftx#IsOpen(), 'Refresh on closed tree doesn''t crash')
  
  call ftx#Focus()
  call s:Assert(1, 'Focus on closed tree doesn''t crash')
  
  try
    call ftx#Open('/this/path/does/not/exist/at/all')
    sleep 100m
    call s:Assert(!ftx#IsOpen(), 'Invalid path doesn''t open')
  catch
    call s:Assert(1, 'Invalid path is handled gracefully')
  endtry
  
  call s:CleanupFTX()
endfunction

function! s:TestMultipleInstances() abort
  echo 'Testing multiple instances...'
  
  call s:CleanupFTX()
  
  call ftx#Open()
  sleep 100m
  let first_bufnr = ftx#GetBufnr()
  call s:Assert(ftx#IsOpen(), 'First instance opens')
  
  call ftx#Open()
  sleep 100m
  let second_bufnr = ftx#GetBufnr()
  call s:Assert(first_bufnr == second_bufnr, 'Second open reuses buffer')
  
  call s:CleanupFTX()
endfunction

function! s:RunTests() abort
  echo ''
  echo '======================================'
  echo '          FTX Test Suite'
  echo '======================================'
  echo ''
  
  call s:TestCommands()
  call s:TestBasicOpen()
  call s:TestToggle()
  call s:TestWindowProperties()
  call s:TestConfiguration()
  call s:TestNavigation()
  call s:TestHiddenFiles()
  call s:TestGitIntegration()
  call s:TestMultipleInstances()
  call s:TestEdgeCases()
  
  call s:CleanupFTX()
  
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