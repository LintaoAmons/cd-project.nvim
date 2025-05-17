# cd-project.nvim v0.11.0 Release Notes

## Major Changes

### Project Position Tracking
- Added functionality to remember the last position in a project, including the last opened file and cursor position
- New configuration option `remember_project_position` to enable/disable this feature (enabled by default)
- Added user commands for manual control:
  - `CdProjectSavePosition`: Manually save the current position in the project
  - `CdProjectRestorePosition`: Manually restore the saved position for the current project
- Position is automatically saved when leaving a buffer or closing Vim, and restored when switching to a project

## Upgrading from v0.10.0
No breaking changes in this release. The new position tracking feature is enabled by default. If you prefer not to use this feature, you can disable it in your configuration:
```lua
require("cd-project").setup({
  remember_project_position = false
})
```

For a complete list of changes, see the [CHANGELOG.md](CHANGELOG.md).
