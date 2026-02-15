# Keymaps

All keyboard shortcuts. Hit `?` inside FTX to see actual mappings.

## Global (anywhere in Vim)

| Mapping | Command | Description |
|---------|---------|-------------|
| `F2` | `:FTXToggle` | Toggle FTX window |
| `F3` | `:FTXRefresh` | Refresh tree |
| `<leader>n` | `:FTXToggle` | Toggle FTX window |
| `<leader>nf` | `:FTXFocus` | Focus FTX window |
| `<leader>nr` | `:FTXRefresh` | Refresh tree |
| `<leader>nh` | `:FTXHelp` | Show help |

## Inside FTX Buffer

### File Operations

| Mapping | Action | Description |
|---------|--------|-------------|
| `o`, `<Return>` | `open` | Open file or toggle directory |
| `gw` | `open:select` | Open with visual window selector |
| `t` | `open:tab` | Open in new tab |
| `s` | `open:split` | Open in horizontal split |
| `v` | `open:vsplit` | Open in vertical split |
| `<2-LeftMouse>` | `open` | Open with double-click |

Selector controls after pressing `gw`:

| Key | Action |
|-----|--------|
| `a..z`, `0..9` (based on labels) | Open in selected window |
| `o`, `<Return>` | Open in previous window (or new window fallback) |
| `t` | Open in new tab |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `q`, `<Esc>` | Cancel |

### Tree Operations

| Mapping | Action | Description |
|---------|--------|-------------|
| `r` | `refresh` | Refresh tree |
| `<C-r>` | `refresh:force` | Force refresh (clear cache) |
| `R` | `refresh:git` | Refresh git status |
| `I` | `toggle:hidden` | Show/hide dotfiles |
| `O` | `expand:all` | Expand all directories |
| `C` | `collapse:all` | Collapse all directories |

### Navigation

| Mapping | Action | Description |
|---------|--------|-------------|
| `-` | `parent` | Go to parent directory |
| `~` | `home` | Go to home directory |
| `cd` | `terminal` | Open terminal in path |

### Git Operations

Only available when `g:ftx_enable_git = 1`:

| Mapping | Action | Description |
|---------|--------|-------------|
| `gi` | `git:branch-info` | Show branch information |
| `gb` | `git:blame` | Show git blame (if enabled) |
| `ig` | `git:toggle-ignored` | Show/hide ignored files |

### Marking Operations

Only available when `g:ftx_enable_marks = 1`:

| Mapping | Action | Description |
|---------|--------|-------------|
| `m` | `mark:toggle` | Toggle mark on current file |
| `M` | `mark:clear` | Clear all marks |
| `mo` | `mark:open-all` | Open all marked files |
| `mg` | `mark:stage-all` | Stage all marked files (git) |

### Yank Operations

| Mapping | Action | Description |
|---------|--------|-------------|
| `yy` | `yank:absolute` | Copy absolute path |
| `yr` | `yank:relative` | Copy relative path |
| `yn` | `yank:name` | Copy filename only |

### Other

| Mapping | Action | Description |
|---------|--------|-------------|
| `?` | `help` | Show this help |
| `q` | `quit` | Close FTX |

## Commands

All commands available from command line:

### Core
```vim
:FTX [path]              " Open FTX at path
:FTXToggle               " Toggle FTX
:FTXClose                " Close FTX
:FTXFocus                " Focus FTX window
:FTXRefresh              " Refresh tree
:FTXRefreshForce         " Force refresh
:FTXClearCache           " Clear tree cache
```

### Tree
```vim
:FTXToggleHidden         " Toggle hidden files
:FTXExpandAll            " Expand all directories
:FTXCollapseAll          " Collapse all directories
:FTXGoParent             " Go to parent directory
:FTXGoHome               " Go to home directory
```

### Git
```vim
:FTXRefreshGit           " Refresh git status
:FTXBranchInfo           " Show branch information
:FTXBlame                " Show git blame (if enabled)
```

### Marks
```vim
:FTXMarkToggle           " Toggle mark
:FTXMarkClear            " Clear all marks
:FTXMarkedOpen           " Open all marked files
:FTXMarkStageAll         " Stage all marked (git)
```

### Yank
```vim
:FTXYankAbsolute         " Yank absolute path
:FTXYankRelative         " Yank relative path
:FTXYankName             " Yank filename
```

### Other
```vim
:FTXCd                   " Open terminal
:FTXHelp                 " Show help
```

## Custom Mappings

Add your own in `.vimrc`:

```vim
" Quick toggle
nnoremap <C-n> :FTXToggle<CR>

" Custom leaders
nnoremap <leader>ft :FTXToggle<CR>
nnoremap <leader>ff :FTXFocus<CR>
nnoremap <leader>fm :FTXMarkToggle<CR>

" Inside FTX buffer
function! s:ftx_mappings() abort
  nmap <buffer> <C-t> <Plug>(ftx-open:tab)
  nmap <buffer> <C-s> <Plug>(ftx-open:split)
  nmap <buffer> <leader>w <Plug>(ftx-open:select)
endfunction

augroup ftx_custom
  autocmd!
  autocmd FileType ftx call s:ftx_mappings()
augroup END
```

## Help Popup

Inside help popup (press `?`):

| Key | Action |
|-----|--------|
| `j`, `<Down>` | Scroll down |
| `k`, `<Up>` | Scroll up |
| `g` | Go to top |
| `G` | Go to bottom |
| Any other | Close help |

## Tips

- All mappings work in normal mode only
- Mouse clicks work if `set mouse=a`
- Use `:verbose map <key>` to debug conflicts
- Press `?` inside FTX for quick reference