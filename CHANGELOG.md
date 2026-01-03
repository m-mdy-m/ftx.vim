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