# Changelog

All notable changes to the cd-project.nvim plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.11.0] - 2025-05-17

### Added
- New feature to remember the last position in a project, including the last opened file and cursor position
- Configuration option `remember_project_position` to toggle this feature (enabled by default)
- User commands `CdProjectSavePosition` and `CdProjectRestorePosition` for manual control over position tracking

### Changed
- Updated project data structure to store last file and cursor position
- Enhanced `cd_project` function to save position before switching and restore position after switching


## [0.10.0] - 2025-05-18

### Added
- Initial plugin implementation
- Project directory detection based on common markers (.git, package.json, etc.)
- Multiple UI adapters (vim-ui and telescope)
- Project configuration storage in JSON format
- Auto-registration of projects (optional)
- Customizable hooks for project directory changes
- Commands for adding and switching between projects

### Changed
- Simplified tab handling by consolidating functionality into the main cd_project function
- Changed keybinding for opening in new tab from <c-o> to <c-t> for better mnemonic association
- Improved tab detection and switching logic
- Enhanced project navigation with multiple context options:
  - Default: Change directory for all windows (`cd`)
  - New tab: Open project in a new tab with `<c-t>` (`tabe | tcd`)
  - Window-local: Change directory only for current window with `<c-e>` (`lcd`)

### Fixed
- Removed redundant cd_project_in_tab function and related code
- Fixed inconsistent indentation in telescope adapter
- Streamlined project directory handling logic
- Improved tab detection to prevent duplicate tabs of the same project

## [0.1.0] - 2025-05-17
- Initial release
