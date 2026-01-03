# Multi-file Marking

Batch operations on multiple files.

## Overview

Mark multiple files for batch operations like opening or staging.

## Basic Usage

**Mark files**
```vim
m               " Toggle mark on current file
```

Marked files show indicator (✓ by default).

**Clear marks**
```vim
M               " Clear all marks
```

**Check marked count**

Shows in statusline: `[3 marked]`

## Operations

**Open all marked files**
```vim
mo              " Open in tabs
:FTXMarkedOpen
```

Opens first file in current window, rest in tabs.

**Stage all marked files**
```vim
mg              " Git add all
:FTXMarkedStage
```

Adds all marked files to git staging area.

## Commands

```vim
:FTXMarkToggle      " Toggle mark
:FTXMarkClear       " Clear all
:FTXMarkedOpen      " Open all
:FTXMarkedStage     " Stage all
```

## Configuration

**Enable/disable**
```vim
let g:ftx_enable_marks = 1
```

**Custom mark icon**
```vim
let g:ftx_icon_marked = '✓'
" Or use other icons:
" let g:ftx_icon_marked = '●'
" let g:ftx_icon_marked = '✔'
" let g:ftx_icon_marked = '▶'
```

## Workflow Examples

**Review and stage changes**
```vim
:FTX                " Open tree
" See modified files (*)
m                   " Mark first file
m                   " Mark second file
m                   " Mark more files
mg                  " Stage all marked
```

**Open related files**
```vim
" Navigate to component
m                   " Mark component.js
" Navigate to test
m                   " Mark test.js
" Navigate to style
m                   " Mark style.css
mo                  " Open all in tabs
```

**Bulk operations**
```vim
" Mark multiple files
m m m m m          " Quick marking
" Check count
" Shows [5 marked] in statusline
mo                 " Open all
```

## Tips

- Marks persist until cleared or operation completes
- Can mark both files and directories
- Only files (not directories) are opened/staged
- Mark count shows in statusline
- Use `M` to quickly clear all marks
- Marks are cleared after `mo` or `mg`

## Limitations

- Marks are session-specific (not saved)
- Cannot mark hidden files if not shown
- Directory marks are ignored for operations
- Maximum practical limit: ~100 marked files