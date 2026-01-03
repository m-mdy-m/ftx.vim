# Git Integration

Complete guide to FTX git features.

## Overview

FTX provides real-time git status, branch information, and blame support.

## Git Status Indicators

Symbols appear before filenames:

```
+ staged.js       Staged for commit
* modified.js     Modified, not staged
? untracked.js    Not tracked by git
- deleted.js      Deleted
! conflict.js     Merge conflict
→ renamed.js      Renamed
◌ ignored.log     Ignored by git
```

## Branch Information

Shows in statusline:

```
myproject [main] ↑2 ↓1 $ [3 marked]
          ↑      ↑  ↑  ↑  ↑
       branch  ahead behind stash marks
```

- `[main]` - Current branch
- `↑2` - 2 commits ahead of remote
- `↓1` - 1 commit behind remote
- `$` - Stash exists
- `[3 marked]` - 3 files marked

## Commands

**Show branch info**
```vim
:FTXBranchInfo  " Popup with details
gi              " Inside FTX
```

**Show git blame**
```vim
:FTXBlame       " Show last 10 commits
gb              " Inside FTX
```

**Refresh status**
```vim
:FTXRefreshGit  " Manual refresh
R               " Inside FTX
```

## Configuration

**Enable/disable**
```vim
let g:ftx_enable_git = 1      " Master switch
let g:ftx_git_status = 1      " Status indicators
```

**Update frequency**
```vim
let g:ftx_git_update_time = 1000  " Milliseconds
```

**Git blame**
```vim
let g:ftx_git_blame = 0       " Off by default
```

**Branch info**
```vim
let g:ftx_show_branch_info = 1
let g:ftx_branch_info_float = 1
```

**Ignored files**
```vim
let g:ftx_show_ignored = 0    " Don't show by default
```

## Workflow Examples

**Check changes before commit**
```vim
:FTX                   " See modified files (*)
R                      " Refresh if needed
gi                     " Check branch status
```

**Multi-file stage**
```vim
m                      " Mark files
m                      " Mark more files
mg                     " Stage all marked
```

**Review commit history**
```vim
" Navigate to file
gb                     " Show blame
" Scroll with j/k
```

## Performance

For large repositories:

```vim
let g:ftx_git_update_time = 3000  " Slower updates
let g:ftx_git_blame = 0           " Disable blame
```

Or disable completely:

```vim
let g:ftx_enable_git = 0
```

## Troubleshooting

**No git status showing**

Check git is installed:
```bash
which git
```

Check you're in a git repo:
```bash
git status
```

Enable git integration:
```vim
let g:ftx_enable_git = 1
let g:ftx_git_status = 1
```

**Slow performance**

Increase update time:
```vim
let g:ftx_git_update_time = 3000
```

**Branch info not showing**

Check popup support:
```vim
:echo has('popupwin')
```

If 0, info will echo instead of popup.