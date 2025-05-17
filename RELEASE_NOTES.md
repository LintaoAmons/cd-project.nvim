# cd-project.nvim v0.10.0 Release Notes

## Major Changes

### Simplified Tab Handling
- Removed the separate `CdProjectTab` command and consolidated functionality into the main `CdProject` command
- Changed keybinding for opening in new tab from `<c-o>` to `<c-t>` for better mnemonic association (t for tab)
- Improved tab detection and switching logic to prevent duplicate tabs of the same project

### Enhanced Project Navigation
Added multiple context options for project navigation:
- Default: Change directory for all windows (`cd`)
- New tab: Open project in a new tab with `<c-t>` (`tabe | tcd`)
- Window-local: Change directory only for current window with `<c-e>` (`lcd`)

### Configuration Improvements
- Moved default configuration to a separate file for better organization
- Set Telescope as the default project picker
- Improved documentation with type annotations

### Code Cleanup
- Removed redundant `cd_project_in_tab` function and related code
- Fixed inconsistent indentation in telescope adapter
- Streamlined project directory handling logic

## Upgrading from v0.9.1
If you were using `CdProjectTab` command or the `<c-o>` keybinding in Telescope, update your workflow:
- Use `CdProject` and press `<c-t>` instead of the old `CdProjectTab` command
- The functionality remains the same but is now more consistent and intuitive

For a complete list of changes, see the [CHANGELOG.md](CHANGELOG.md).
