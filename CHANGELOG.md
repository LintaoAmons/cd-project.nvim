# Changelog

All notable changes to the cd-project.nvim plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New `snacks` picker adapter (`projects_picker = "snacks"`) built on [snacks.nvim](https://github.com/folke/snacks.nvim), with the same keymaps as the Telescope picker: `<cr>` cd, `<c-t>` tab, `<c-e>` window, `<c-d>` delete, `<c-r>` rename (delete/rename refresh the picker in place)
- `CdProjectSearchAndAdd` and `CdProjectDelete` now respect `projects_picker` instead of always using Telescope

### Changed
- Extracted shared picker helpers (entry sorting, column formatting) into `cd-project.adapter.common`, used by both the Telescope and snacks adapters

### Fixed
- `CdProjectBack` no longer errors when there is no previous project to go back to
- Removed leftover `cd_project_in_tab` in the vim-ui adapter that called a deleted API function and would always error
- Projects whose directory is temporarily missing (e.g. an unmounted drive) are no longer permanently dropped from the json file by add/delete/rename/cd — they are only hidden from the picker while missing
- `format_json = false` is now respected (jq formatting used to run whenever jq was installed); a jq failure now falls back to unformatted output instead of erroring
- A corrupted projects json file no longer crashes the plugin (warns and starts with an empty list, leaving the file untouched)
- `setup()` no longer deep-merges the `hooks` list by index: user hooks fully replace the default hooks instead of mixing with them
- Remembered positions are stored relative to the project root instead of the current working directory; files outside the project are no longer remembered
- Position tracking no longer rewrites the json file (and spawns jq) on every `BufLeave` when nothing changed
- Restoring a position no longer aborts the cd when the current buffer has unsaved changes

## [1.0.0] - 2025-05-20

### Added
- Refactored Telescope adapter to follow a modular pattern similar to bookmarks.nvim with a `format_entry` method
- Added functionality to delete project entries using `<c-d>` in the Telescope picker
- Introduced unique project IDs to ensure accurate deletion of projects with duplicate names
- Added support for opening projects in split and vertical split views in Telescope picker
- Enhanced hooks system to filter by `cd_cmd` type

### Changed
- **Breaking Change**: Updated project data structure to include a mandatory unique `id` field. Existing projects without an ID will be automatically assigned one, but custom scripts or tools relying on the old structure may need updates.
- Modified project deletion logic to use unique IDs instead of names for improved accuracy
- Improved `cd_project` function to pass `cd_cmd` to hooks for better customization
- Reordered execution in `cd_project` to restore position before executing AFTER_CD hooks
- Removed debug print statements from `position.lua` for cleaner operation

## [0.12.0] - 2025-05-18

### Added
- New feature to sort projects in the Telescope picker by last visited time (`visited_at`)
- Current project is always placed at the bottom of the project list in the picker

### Changed
- Updated project data structure to include `visited_at` timestamp
- Enhanced project retrieval to sort by last visited time
- Modified `cd_project` function to update `visited_at` timestamp on project switch
- Adjusted Telescope adapter to move the current project to the end of the list


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
