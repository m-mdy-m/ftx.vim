# Changelog

All notable changes to FTX are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2025-01-03

### Added

#### Dev
- Initial project structure
- Basic tree rendering
- Git status prototype
- Test framework setup

#### Core Features
- Async file tree rendering using Vim's job API
- Real-time directory traversal with non-blocking operations
- Tree expansion/collapse for directories
- Hidden files toggle (show/hide files starting with .)
- Configurable window width and position
- Auto-close option when FTX is last remaining window
- Mouse click support for file opening

#### Git Integration
- Async git status checking with job API
- Timer-based automatic status updates (default: 1000ms)
- Git repository detection by walking directory tree
- Branch tracking information (ahead/behind commits)
- Stash detection
- File status indicators:
  - `*` Modified files (uncommitted changes)
  - `+` Staged files (ready for commit)
  - `?` Untracked files (not in git index)
  - `$` Stash exists in repository
  - `↑n` Ahead by n commits
  - `↓n` Behind by n commits
- Status updates on file save and buffer changes
- Proper cleanup of git jobs on exit

#### User Interface
- Clean tree display with Unicode icons (▸ ▾)
- Indentation-based hierarchy visualization
- Syntax highlighting for:
  - Directories
  - Files
  - Tree icons
  - Git status indicators
- Cursorline highlighting for current item
- No line numbers (cleaner display)
- Non-modifiable buffer (prevents accidental edits)

#### File Operations
- Open files in current window
- Open files in new tab
- Open files in horizontal split
- Open files in vertical split
- Smart window selection (finds suitable existing window)
- Creates new window if no suitable window exists

#### Configuration Options
- `g:ftx_width` - Tree window width (default: 30)
- `g:ftx_position` - Window position: 'left' or 'right' (default: 'left')
- `g:ftx_show_hidden` - Show hidden files (default: 0)
- `g:ftx_git_status` - Enable git integration (default: 1)
- `g:ftx_sort_dirs_first` - Sort directories before files (default: 1)
- `g:ftx_auto_close` - Auto close when last window (default: 0)
- `g:ftx_git_update_time` - Git update interval in ms (default: 1000)

#### Commands
- `:FTX [path]` - Open FTX in specified path or current directory
- `:FTXToggle` and `F2` - Toggle FTX window visibility
- `:FTXClose` - Close FTX window
- `:FTXRefresh` - Refresh tree display
- `:FTXFocus` - Focus FTX window

#### Keymaps
- `o` / `Enter` - Open file or toggle directory
- `t` - Open in new tab
- `s` - Open in horizontal split
- `v` - Open in vertical split
- `r` / `R` - Refresh tree
- `I` - Toggle hidden files
- `q` - Close FTX
- `<2-LeftMouse>` - Open file or toggle directory

#### Architecture
- Async operations prevent UI blocking

#### Documentation
- Complete user documentation in markdown format
- Installation instructions for multiple package managers
- Configuration examples
- Usage guide with all commands and keymaps
- Git integration explanation
- Troubleshooting section
- Integration guide for VEX editor
- Contributing guidelines
- Changelog with detailed version history

[Unreleased]: https://github.com/m-mdy-m/ftx.vim/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/m-mdy-m/ftx.vim/releases/tag/v0.1.0

## [Released]

## [0.2.0] - 2026-01-03

### Added

#### Core
- Test infrastructure for validating core functionality
- Example configuration file for easier onboarding
- `.PHONY` targets for development and maintenance tasks
- Screenshot showcasing FTX UI and tree layout

#### Git Integration
- Git branch information in statusline (branch, ahead/behind)
- Improved git status rendering accuracy
- Better handling of git job lifecycle and cleanup

#### Documentation
- Expanded README with clearer usage instructions
- Added configuration examples
- Updated project metadata and documentation year

### Fixed
- Incorrect git status propagation for nested directories
- Statusline not updating after git refresh
- Minor inconsistencies in tree rendering after refresh

### Changed
- Improved internal git status update flow
- Refined statusline update logic for better UX

[0.2.0]: https://github.com/m-mdy-m/ftx.vim/releases/tag/v0.2.0

## [0.3.0] - 2026-01-03

### Added

#### Major New Features
- **Auto-sync**: Tree automatically syncs to show current file when switching buffers
  - Expands directories automatically to reveal current file
  - Configurable with `g:ftx_auto_sync` (default: 1)
  - Intelligent detection to avoid unnecessary updates

- **Multi-file Marking System**: Mark multiple files for batch operations
  - Toggle marks with `m` key
  - Visual mark indicator (`✓` by default)
  - Mark counter in status line
  - Operations:
    - `mo` - Open all marked files in tabs
    - `mg` - Stage all marked files to git
    - `M` - Clear all marks
  - Configurable with `g:ftx_enable_marks`

- **Tree Operations**: Expand/collapse entire tree
  - `O` - Expand all directories
  - `C` - Collapse all directories
  - `:FTXExpandToDepth N` - Expand to specific depth
  - Useful for navigating large projects

- **Terminal Integration**: Open terminal in selected path
  - `cd` key or `:FTXOpenTerminal` command
  - Opens terminal in file's directory or selected directory
  - Smart window selection
  - Works with both Vim and Neovim terminals

- **Interactive Help Float**: Built-in help system
  - Press `?` inside FTX or use `:FTXHelp`
  - Shows all keymaps in a popup window
  - Scrollable with j/k keys
  - Close with any key
  - Falls back to echo if popups not available

#### Git Enhancements
- **Fixed Git Blame**: Properly working blame popup
  - Shows last 10 commits for selected file
  - Displays commit hash, author, time, and message
  - Scrollable popup with formatted output
  - Close with any key (Esc, q, Space, Enter)

- **Fixed Branch Info Popup**: Proper popup handling
  - Shows branch name, ahead/behind commits, stash status
  - Properly closes with any key
  - Scrollable content
  - Better formatting with box-drawing characters

- **Ignored Files in Git Status**: Show gitignore files when enabled
  - Respects `g:ftx_show_ignored` setting
  - Uses custom icon for ignored files

#### Documentation
  Detailed Documentation:
  - [Complete Guide](doc/README.md) - Start here
  - [Configuration](doc/configuration.md) - All settings
  - [Keymaps](doc/keymaps.md) - Keyboard shortcuts
  - [Git Integration](doc/git.md) - Git features
  - [Multi-file Marking](doc/marks.md) - Batch operations
  - [Customization](doc/customization.md) - Icons and styling
  
#### Commands
New commands added:
- `:FTXHelp` - Show interactive help
- `:FTXExpandAll` - Expand all directories
- `:FTXCollapseAll` - Collapse all directories
- `:FTXExpandToDepth N` - Expand to specific depth
- `:FTXOpenTerminal` - Open terminal in path
- `:FTXMarkToggle` - Toggle mark
- `:FTXMarkClear` - Clear all marks
- `:FTXMarkedOpen` - Open marked files
- `:FTXMarkedStage` - Stage marked files

#### Keymaps
New keymaps inside FTX:
- `?` - Show help
- `O` - Expand all
- `C` - Collapse all
- `ig` - Toggle ignored files
- `yy` - Copy path
- `cd` - Open terminal
- `m` - Toggle mark
- `M` - Clear marks
- `mo` - Open marked
- `mg` - Stage marked
- `gb` - Git blame
- `gi` - Git branch info

New global keymaps:
- `<leader>nh` - Show help

#### Configuration Options
New configuration variables:
- `g:ftx_auto_sync` - Auto-sync on buffer change (default: 1)
- `g:ftx_enable_marks` - Enable marking system (default: 1)
- `g:ftx_show_ignored` - Show gitignore files (default: 0)
- `g:ftx_icon_marked` - Mark indicator icon (default: '✓')

### Changed
- **Improved Popup Handling**: All popups now close properly
  - Fixed GitBranchInfo popup not closing
  - Fixed Git Blame popup issues
  - Better keyboard navigation in popups
  - Consistent behavior across all popups

- **Enhanced Renderer**: Better performance and features
  - Support for mark indicators
  - Better icon handling
  - Optimized tree building
  - Smart sync to current file

- **Better Git Status Updates**: More reliable and faster
  - Handles ignored files correctly
  - Better error handling
  - Improved async job management
  - Reduced unnecessary updates

- **Improved Help Documentation**: Complete and accurate
  - All features documented
  - Better examples
  - Proper Vim help format
  - Working help tags

### Fixed
- **Critical**: Popups close properly
  - GitBranchInfo popup closes on any key
  - Git Blame popup closes correctly
  - Help popup closes as expected
  - No stuck popups

- **Git Status**: Improved reliability
  - Better status parsing
  - Correct ignored file detection
  - Fixed race conditions
  - Better job cleanup

- **Renderer**: Various fixes
  - Correct mark display
  - Better icon positioning
  - Fixed sync issues
  - Improved cursor positioning

- **Auto-sync**: Smart buffer detection
  - Avoids unnecessary updates
  - Correct file detection
  - Better performance
  - No false triggers

### Performance
- **Optimized Tree Rendering**: Faster with large directories
- **Better Job Management**: Reduced memory usage
- **Smart Auto-sync**: Only updates when needed
- **Efficient Mark Tracking**: Minimal overhead

### Testing
- **Enhanced CI/CD**: More comprehensive tests
  - Tests for new features
  - Popup functionality tests
  - Help tag generation verification
  - Multiple Vim versions (8.2, 9.0, 9.1, nightly)

[0.3.0]: https://github.com/m-mdy-m/ftx.vim/releases/tag/v0.3.0

## [0.4.0] - 2026-01-05

### Added

* Full support for file-specific icons and colors
* New documentation for icons, colors, and customization
* New commands and configuration options for modular codebase
* Example configuration and updated screenshots for easier onboarding

### Changed

* Refactored regex and syntax handling for better color highlighting
* Updated internal logic for modular code
* Improved CI and build scripts

### Fixed

* Fixed syntax-style loading to avoid startup errors
* Corrected display of colors and highlights
* Fixed git status propagation and statusline issues

### Documentation

* Updated README and docs for clarity and examples
* Added modular codebase guide and customization examples

[Released]: https://github.com/m-mdy-m/ftx.vim/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/m-mdy-m/ftx.vim/releases/tag/v0.4.0

## [1.0.0] - 2026-01-08

### ⚠️ Breaking Changes

This is a complete rewrite of FTX with new architecture and APIs.

### Added

#### Core Architecture
- New async engine with promise-based API (#17, #15)
- Task queue system with worker pool
- Channel-based inter-task communication
- Git-like tree/blob caching system (#21)
- Modular renderer architecture (#27)

#### Features
- **Drawer Mode**: NERDTree-style project drawer (#33)
- **Testing Framework**: Themis test infrastructure (#35)
- **Help System**: Complete Vim documentation (`:help ftx`) (#36)
- **CI/CD**: Automated releases via GitHub Actions

#### Platform Support
- Full Neovim compatibility
- Windows OS support (#31)
- macOS and Linux testing
- Vim 8.0+ and Neovim 0.4+

### Changed

#### Refactored Components
- Tree rendering rewritten from scratch (#29)
- Git status integration redesigned (#32, #33)
- Command system restructured (#22)
- Mapping system reorganized (#25)
- Internal buffer/window management (#23, #28)
- Helper utilities modularized (#19)

### Fixed

- Syntax highlighting persistence (#34)
- Yank filepath functionality
- Neovim-specific compatibility issues
- Promise chain error handling (#29)
- Git renderer color display

### Documentation

- Added `doc/ftx.txt` - comprehensive help file
- Reorganized to `doc/` directory structure
- See `:help ftx` for complete reference

### Development

- CI for Vim/Neovim across OS
- Automated release workflow

---

**Migration Notes**: This is a major rewrite. Configuration and APIs are compatible, but internal structure has completely changed.

[1.0.0]: https://github.com/m-mdy-m/ftx.vim/releases/tag/v1.0.0

## [1.0.1] - 2026-01-08

### Added

* Support for `-drawer` flag in FTX command
* Open FTX with `vim .` automatically

### Fixed

* FTX command argument parsing issue

[1.0.1]: https://github.com/m-mdy-m/ftx.vim/releases/tag/v1.0.1
