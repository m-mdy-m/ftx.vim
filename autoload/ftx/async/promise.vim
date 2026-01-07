" ----------------------------------------------------------------------
" Copyright (c) 2026 m-mdy-m
" MIT License
"
" Promise wrapper over goroutine-style scheduler
" Provides clean, chainable async API
" ----------------------------------------------------------------------

function! ftx#async#promise#new(executor) abort
  let promise = {
        \ '_state': 'pending',
        \ '_value': v:null,
        \ '_handlers': [],
        \ 'then': function('s:then'),
        \ 'catch': function('s:catch'),
        \ }
  
  try
    call a:executor(
          \ function('s:resolve', [promise]),
          \ function('s:reject', [promise])
          \ )
  catch
    call s:reject(promise, v:exception)
  endtry
  
  return promise
endfunction

function! s:resolve(promise, value) abort
  if a:promise._state !=# 'pending'
    return
  endif
  
  let a:promise._state = 'fulfilled'
  let a:promise._value = a:value
  call ftx#async#internal#queue#schedule(function('s:handle_promise'), a:promise)
endfunction

function! s:reject(promise, reason) abort
  if a:promise._state !=# 'pending'
    return
  endif
  
  let a:promise._state = 'rejected'
  let a:promise._value = a:reason

  call ftx#async#internal#queue#schedule(function('s:handle_promise'), a:promise)
endfunction

function! s:handle_promise(promise) abort
  
  for handler in a:promise._handlers
    try
      if a:promise._state ==# 'fulfilled'
        if handler.on_fulfill isnot v:null
          let result = handler.on_fulfill(a:promise._value)

          if type(result) == type({}) && has_key(result, 'then')
            call result.then(
                  \ {v -> s:resolve(handler.next, v)},
                  \ {e -> s:reject(handler.next, e)}
                  \ )
          else
            call s:resolve(handler.next, result)
          endif
        else
          call s:resolve(handler.next, a:promise._value)
        endif

      elseif a:promise._state ==# 'rejected'
        if handler.on_reject isnot v:null
          let result = handler.on_reject(a:promise._value)

          if type(result) == type({}) && has_key(result, 'then')
            call result.then(
                  \ {v -> s:resolve(handler.next, v)},
                  \ {e -> s:reject(handler.next, e)}
                  \ )
          else
            call s:resolve(handler.next, result)
          endif
        else
          call s:reject(handler.next, a:promise._value)
        endif
      endif

    catch
      call s:reject(handler.next, v:exception)
    endtry
  endfor

  let a:promise._handlers = []
endfunction


function! s:then(on_fulfill, ...) abort dict
  let OnReject = get(a:000, 0, v:null)
  let next_promise = ftx#async#promise#new({res, rej -> 0})
  
  let handler = {
        \ 'on_fulfill': a:on_fulfill,
        \ 'on_reject': OnReject,
        \ 'next': next_promise,
        \ }
  
  call add(self._handlers, handler)
  
  if self._state !=# 'pending'
    call ftx#async#internal#queue#schedule(
          \ function('s:handle_promise'),
          \ self
          \ )
  endif
  
  return next_promise
endfunction

function! s:catch(on_reject) abort dict
  return self.then(v:null, a:on_reject)
endfunction

"helpers
function! ftx#async#promise#resolve(value) abort
  return ftx#async#promise#new({res, rej -> res(a:value)})
endfunction

function! ftx#async#promise#reject(reason) abort
  return ftx#async#promise#new({res, rej -> rej(a:reason)})
endfunction

function! ftx#async#promise#all(promises) abort
  if empty(a:promises)
    return ftx#async#promise#resolve([])
  endif
  
  return ftx#async#promise#new({resolve, reject ->
        \ s:promise_all_executor(a:promises, resolve, reject)
        \ })
endfunction

function! s:promise_all_executor(promises, resolve, reject) abort
  let state = {
        \ 'results': repeat([v:null], len(a:promises)),
        \ 'completed': 0,
        \ 'total': len(a:promises),
        \ }
  
  for idx in range(len(a:promises))
    call a:promises[idx].then(
          \ function('s:on_all_fulfill', [state, idx, a:resolve]),
          \ a:reject
          \ )
  endfor
endfunction

function! s:on_all_fulfill(state, idx, resolve, value) abort
  let a:state.results[a:idx] = a:value
  let a:state.completed += 1
  
  if a:state.completed == a:state.total
    call a:resolve(a:state.results)
  endif
endfunction