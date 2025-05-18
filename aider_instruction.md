# Aider Instructions for cd-project.nvim

This document provides instructions for Aider to assist with maintaining the `cd-project.nvim` plugin, a Neovim plugin designed to simplify project directory navigation and management. The plugin allows users to add, persist, and switch between project directories efficiently. Below are guidelines for updating documentation files and understanding key plugin features like project patterns.

## Overview of cd-project.nvim

`cd-project.nvim` is focused on enhancing the Neovim experience by providing a streamlined way to manage project directories. Key features include:
- **Project Detection**: Automatically detects project directories based on common markers like `.git`, `.gitignore`, `Cargo.toml`, `package.json`, and `go.mod`.
- **Project Switching**: Offers commands and UI pickers (Telescope and vim-ui) to switch between registered projects.
- **Persistence**: Stores project configurations in a JSON file for real-time updates.
- **Customization**: Supports hooks for custom actions before and after directory changes, and configurable project patterns.

## Project Patterns

The plugin uses configurable patterns to identify project directories. By default, it looks for specific files or directories that indicate the root of a project. These patterns are defined in the configuration as `project_dir_pattern` and can be customized by users. The default patterns are:
- `.git`
- `.gitignore`
- `Cargo.toml`
- `package.json`
- `go.mod`

When contributing to the plugin, ensure that any changes related to project detection respect or enhance this configurable approach. If modifying or extending the default patterns, update the documentation and configuration options accordingly. Also, note that the `.gitignore` file includes entries like `.project_positions.json` to ignore project position data files, which should be considered when dealing with file persistence or storage mechanisms.

## Updating CHANGELOG.md

When making changes to the codebase, follow these steps to update the `CHANGELOG.md` file:

1. **Version Entry**: If the change is part of a new version, create a new version entry at the top of the changelog (right after the initial headings). Use the format `## [X.Y.Z] - YYYY-MM-DD` where `X.Y.Z` is the new version number following Semantic Versioning, and `YYYY-MM-DD` is the release date.
2. **Categorize Changes**: Under the new version entry, categorize the changes into sections such as `Added`, `Changed`, `Fixed`, etc., as per the Keep a Changelog format.
3. **Describe Changes**: For each change, provide a concise bullet point description that clearly explains what was modified or added. Reference the specific feature or fix, and if applicable, link to the relevant GitHub issue or pull request.
4. **Preserve Existing Content**: Ensure that existing changelog entries are not modified or removed. Only add new content for the current changes.

Example:
```
## [0.13.0] - 2025-05-20

### Added
- New feature to support unique project IDs for accurate deletion

### Changed
- Updated project deletion logic to use unique IDs instead of names
```

## Updating RELEASE_NOTES.md

When preparing a new release, update the `RELEASE_NOTES.md` file with the following structure:

1. **Title**: Update the title to reflect the new version, e.g., `# cd-project.nvim vX.Y.Z Release Notes`.
2. **Major Changes**: Under `## Major Changes`, describe the significant updates or features introduced in this version. Provide a brief overview of each major change with a subheading if necessary.
3. **Upgrading Instructions**: Under `## Upgrading from vX.Y.Z`, inform users about any breaking changes or specific steps needed to upgrade from the previous version. If there are no breaking changes, state that explicitly.
4. **Reference to Changelog**: At the end, include a link to the `CHANGELOG.md` for a complete list of changes.

Example:
```
# cd-project.nvim v0.13.0 Release Notes

## Major Changes

### Unique Project IDs
- Introduced unique IDs for projects to ensure accurate deletion even when projects share the same name.

## Upgrading from v0.12.0
No breaking changes in this release. The unique ID feature is automatically applied to new and existing projects. No additional configuration is needed.

For a complete list of changes, see the [CHANGELOG.md](CHANGELOG.md).
```

## General Guidelines

- **Consistency**: Maintain consistency in formatting and style with existing entries in both files.
- **Versioning**: Follow Semantic Versioning for version numbers (MAJOR.MINOR.PATCH).
- **Clarity**: Write clear, user-friendly descriptions that help users understand the impact of changes.
- **Timeliness**: Update these files as part of the release preparation process to ensure they are ready for users when the new version is tagged.

By following these instructions, Aider can help maintain accurate and helpful documentation for `cd-project.nvim` releases.
