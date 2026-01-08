# Git Integration

Git features in FTX.

## Overview

FTX shows real-time git status indicators next to files and directories. It also provides branch information and git blame support.

## Git Status Indicators

Symbols before filenames show git status:

```
+ staged.js         Staged for commit (added to index)
* modified.js       Modified but not staged
? untracked.js      Not tracked by git
- deleted.js        Deleted file
! conflict.js       Merge conflict
→ renamed.js        Renamed file
◌ ignored.log       Ignored by gitignore (if shown)
```

Directories show their children's status. A directory marked with `*` means it contains modified files.

## Branch Information

Press `gi` inside FTX to see:
- Current branch name
- Commits ahead of remote
- Commits behind remote
- Whether stash exists

Example output:
```
╔═══════════════════════════════╗
║   Git Branch Information      ║
╠═══════════════════════════════╣
║                               ║
║  Branch: main                 ║
║  Ahead:  ↑ 2 commits          ║
║  Behind: ↓ 1 commits          ║
║  Stash:  $ exists             ║
║                               ║
╚═══════════════════════════════╝
```

## Git Blame

If enabled, press `gb` on a file to see last 10 commits:

```vim
let g:ftx_git_blame = 1
```

Shows:
- Commit hash
- Author
- Time ago
- Commit message

Navigate with `j`/`k`, close with any other key.

## Commands

```vim
:FTXRefreshGit      " Manually refresh git status
:FTXBranchInfo      " Show branch info popup
:FTXBlame           " Show git blame (if enabled)
```

## Configuration

### Enable/Disable

```vim
let g:ftx_enable_git = 1        " Master switch (default: 1)
let g:ftx_git_status = 1        " Show status indicators (default: 1)
let g:ftx_git_blame = 0         " Enable blame feature (default: 0)
```

### Update Frequency

```vim
let g:ftx_git_update_time = 2000  " Update interval in ms (default: 2000)
```

Lower value = more frequent updates = more CPU usage.

### Show Ignored Files

```vim
let g:ftx_show_ignored = 0      " Don't show by default
```

Toggle inside FTX with `ig` key.

### Custom Icons

```vim
let g:ftx_git_icon_added = '+'
let g:ftx_git_icon_modified = '*'
let g:ftx_git_icon_deleted = '-'
let g:ftx_git_icon_renamed = '→'
let g:ftx_git_icon_untracked = '?'
let g:ftx_git_icon_ignored = '◌'
let g:ftx_git_icon_unmerged = '!'
```

## Workflows

### Check Status Before Commit

```vim
:FTX
" See modified files marked with *
" See untracked files marked with ?
R           " Refresh if needed
gi          " Check branch status
```

### Stage Multiple Files

```vim
" Mark files with m
m
m
m
" Stage all marked
mg
```

### Review History

```vim
" Navigate to file
gb          " Show blame
" Scroll with j/k
" Close with any key
```

## Performance

### Large Repositories

For big repos, git operations can slow down FTX. Optimize:

```vim
let g:ftx_git_update_time = 5000    " Slower updates
let g:ftx_git_blame = 0             " Disable blame
```

Or disable git entirely:

```vim
let g:ftx_enable_git = 0
```

### Fast Updates

For small repos, faster updates:

```vim
let g:ftx_git_update_time = 1000    " Update every second
```

## Troubleshooting

**No git status showing**

Check git is installed:
```bash
which git
```

Check you're in a git repository:
```bash
git status
```

Enable git in FTX:
```vim
let g:ftx_enable_git = 1
let g:ftx_git_status = 1
```

**Slow performance**

Increase update interval:
```vim
let g:ftx_git_update_time = 5000
```

**Branch info not showing**

Check popup support:
```vim
:echo has('popupwin')
```

If returns `0`, info will echo instead of popup.

**Blame not working**

Enable it first:
```vim
let g:ftx_git_blame = 1
```

Then restart Vim or `:source $MYVIMRC`.

## Tips

- Git status updates automatically on file save
- Press `R` to force refresh
- Use `ig` to toggle ignored files visibility
- Marked files show with `✓` symbol
- Stage marked files with `mg`