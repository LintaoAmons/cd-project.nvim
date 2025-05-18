# cd-project.nvim v0.12.1 Release Notes

## Major Changes

### Telescope Picker Enhancements
- Refactored the Telescope adapter for better modularity and added functionality to delete projects directly from the picker using `<c-d>`.
- Added support for opening projects in horizontal and vertical splits using Telescope's built-in keybindings.

### Unique Project Identification
- Introduced unique IDs for projects to ensure accurate deletion, especially when multiple projects share the same name.

### Hooks System Improvement
- Enhanced the hooks system to allow filtering based on the type of directory change command (`cd`, `tabe | tcd`, `lcd`), providing more granular control over hook execution.

## Upgrading from v0.12.0
No breaking changes in this release. The new features and improvements are automatically applied:
- Unique project IDs are generated for new projects and used for deletion operations.
- Telescope picker enhancements are available immediately with the updated keybindings.
- Hooks can now be configured to trigger based on specific directory change commands.

For a complete list of changes, see the [CHANGELOG.md](CHANGELOG.md).
