# cd-project.nvim v1.0.0 Release Notes

## Major Changes

### Breaking Change: Mandatory Unique Project ID Field
- Introduced a mandatory unique `id` field in the project data structure to ensure accurate identification and deletion of projects, especially when names are duplicated. Existing projects will be automatically updated with an ID, but custom scripts or integrations relying on the previous data structure may need to be updated.

### Telescope Picker Enhancements
- Refactored the Telescope adapter for better modularity and added functionality to delete projects directly from the picker using `<c-d>`.
- Added support for opening projects in horizontal and vertical splits using Telescope's built-in keybindings.

### Hooks System Improvement
- Enhanced the hooks system to allow filtering based on the type of directory change command (`cd`, `tabe | tcd`, `lcd`), providing more granular control over hook execution.

## Upgrading from v0.12.1
**Important**: This release includes a breaking change. The project data structure now requires a unique `id` field. While the plugin will automatically assign IDs to existing projects, any custom scripts or external tools that parse or manipulate the project JSON file may need to be updated to handle this new field. Please review your scripts and update them to use the `id` field for project identification and deletion operations.

For a complete list of changes, see the [CHANGELOG.md](CHANGELOG.md).
