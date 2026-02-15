# Developer Guide

FTX now provides a focused extension API for real plugin integrations.

## Goals

- Keep the core file-tree behavior stable.
- Expose a **small API surface** for plugin authors.
- Support integrations like `fzf`, debugger launchers, and custom open flows.

## Public API

### Events

Register event handlers:

```vim
call ftx#api#on('tree:opened', function('MyPluginOnTreeOpen'))
call ftx#api#on('tree:rendered', function('MyPluginOnTreeRendered'))
call ftx#api#on('tree:closed', function('MyPluginOnTreeClosed'))
call ftx#api#on('file:opened', function('MyPluginOnFileOpened'))
```

Event payloads:

- `tree:opened`: `{ root }`
- `tree:rendered`: `{ root, node_count }`
- `tree:closed`: `{ root }`
- `file:opened`: `{ path, node, opener }`

### Openers

Register a custom opener:

```vim
function! MyFzfOpener(path, ctx) abort
  execute 'tabedit ' . fnameescape(a:path)
  " or call your own picker/debug flow
endfunction

call ftx#api#register_opener('fzf', function('MyFzfOpener'))
```

Invoke on current node:

```vim
nnoremap <buffer> <silent> <leader>of :<C-u>call ftx#api#open_node_with('fzf', ftx#tree#ui#get_cursor_node())<CR>
```

Built-in opener names:

- `edit`
- `split`
- `vsplit`
- `tabedit`

## Integration examples

### Debugger integration

```vim
function! MyDebuggerOpen(path, ctx) abort
  execute 'edit ' . fnameescape(a:path)
  " Example: set a breakpoint at line 1
  " call vimspector#SetLineBreakpoint(expand('%:p'), 1)
endfunction

call ftx#api#register_opener('debug', function('MyDebuggerOpen'))
nnoremap <buffer> <silent> <leader>od :<C-u>call ftx#api#open_node_with('debug', ftx#tree#ui#get_cursor_node())<CR>
```

## Design rules for extension authors

- Keep callbacks fast; offload expensive work.
- Treat payloads as read-only.
- Prefer `ftx#api#register_opener()` over monkey-patching core functions.
- Avoid relying on script-local internals under `autoload/ftx/internal`.