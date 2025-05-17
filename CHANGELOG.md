# Changelog

All notable changes to the cd-project.nvim plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

### Fixed
- Removed redundant cd_project_in_tab function and related code
- Fixed inconsistent indentation in telescope adapter
- Streamlined project directory handling logic

## [0.1.0] - 2025-05-17
- Initial release
