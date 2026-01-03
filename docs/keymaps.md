# Keymaps

All keyboard shortcuts for FTX.

## Global (anywhere in Vim)

| Key | Action |
|-----|--------|
| `F2` | Toggle FTX |
| `F3` | Refresh FTX |
| `<leader>n` | Toggle FTX |
| `<leader>nf` | Focus FTX |
| `<leader>nr` | Refresh FTX |
| `<leader>nh` | Show help |

## Inside FTX Window

### Basic Operations

| Key | Action |
|-----|--------|
| `o` or `Enter` | Open file / Toggle directory |
| `t` | Open in new tab |
| `s` | Open in horizontal split |
| `v` | Open in vertical split |
| `-` | Go to parent directory |
| `~` | Go to home directory |

### Tree Operations

| Key | Action |
|-----|--------|
| `r` | Refresh tree |
| `R` | Refresh git status |
| `I` | Toggle hidden files |
| `O` | Expand all directories |
| `C` | Collapse all directories |

### Multi-file Marking

| Key | Action |
|-----|--------|
| `m` | Toggle mark on current item |
| `M` | Clear all marks |
| `mo` | Open all marked files |
| `mg` | Stage all marked files (git) |

### File Operations

| Key | Action |
|-----|--------|
| `cd` | Open terminal in current path |

### Git Operations

| Key | Action |
|-----|--------|
| `gb` | Show git blame |
| `gi` | Show branch info |

### Other

| Key | Action |
|-----|--------|
| `?` | Show help popup |
| `q` | Close FTX |

## Custom Mappings

Add your own shortcuts in `.vimrc`:

```vim
" Quick toggle
nnoremap <C-n> :FTXToggle<CR>

" Custom leader mappings
nnoremap <leader>ft :FTXToggle<CR>
nnoremap <leader>ff :FTXFocus<CR>
nnoremap <leader>fb :FTXBranchInfo<CR>
nnoremap <leader>fm :FTXMarkToggle<CR>
```

## Inside Help Popup

| Key | Action |
|-----|--------|
| `j` or `Down` | Scroll down |
| `k` or `Up` | Scroll up |
| `g` | Go to top |
| `G` | Go to bottom |
| Any other key | Close help |

## Tips

- Use `?` for quick reference inside FTX
- Mouse clicks work for opening files
- All keymaps work in normal mode only
- Commands available from command line (`:FTX...`)