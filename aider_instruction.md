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

## Version Upload Convention

When updating the version of `cd-project.nvim`, follow Semantic Versioning (MAJOR.MINOR.PATCH):
- **MAJOR version** (first number) is incremented for breaking changes that are not backward compatible.
- **MINOR version** (second number) is incremented for new features that are backward compatible.
- **PATCH version** (third number) is incremented for bug fixes or minor changes that are backward compatible.

Ensure that any breaking changes result in a major version increment (e.g., from 0.12.1 to 1.0.0).

## General Guidelines

- **Consistency**: Maintain consistency in formatting and style with existing entries in both files.
- **Versioning**: Follow Semantic Versioning for version numbers (MAJOR.MINOR.PATCH).
- **Clarity**: Write clear, user-friendly descriptions that help users understand the impact of changes.
- **Timeliness**: Update these files as part of the release preparation process to ensure they are ready for users when the new version is tagged.

## *SEARCH/REPLACE Block* Rules

Every *SEARCH/REPLACE block* must use this format:
1. The *FULL* file path alone on a line, verbatim. No bold asterisks, no quotes around it, no escaping of characters, etc.
2. The opening fence and code language, eg: ````python
3. The start of search block: <<<<<<< SEARCH
4. A contiguous chunk of lines to search for in the existing source code
5. The dividing line: =======
6. The lines to replace into the source code
7. The end of the replace block: >>>>>>> REPLACE
8. The closing fence: ````

Use the *FULL* file path, as shown to you by the user.

IMPORTANT: Use *quadruple* backticks ```` as fences, not triple backticks!

Every *SEARCH* section must *EXACTLY MATCH* the existing file content, character for character, including all comments, docstrings, etc.
If the file contains code or other data wrapped/escaped in json/xml/quotes or other containers, you need to propose edits to the literal contents of the file, including the container markup.

*SEARCH/REPLACE* blocks will *only* replace the first match occurrence.
Including multiple unique *SEARCH/REPLACE* blocks if needed.
Include enough lines in each SEARCH section to uniquely match each set of lines that need to change.

Keep *SEARCH/REPLACE* blocks concise.
Break large *SEARCH/REPLACE* blocks into a series of smaller blocks that each change a small portion of the file.
Include just the changing lines, and a few surrounding lines if needed for uniqueness.
Do not include long runs of unchanging lines in *SEARCH/REPLACE* blocks.

Only create *SEARCH/REPLACE* blocks for files that the user has added to the chat!

To move code within a file, use 2 *SEARCH/REPLACE* blocks: 1 to delete it from its current location, 1 to insert it in the new location.

Pay attention to which filenames the user wants you to edit, especially if they are asking you to create a new file.

If you want to put code in a new file, use a *SEARCH/REPLACE block* with:
- A new file path, including dir name if needed
- An empty `SEARCH` section
- The new file's contents in the `REPLACE` section

To rename files which have been added to the chat, use shell commands at the end of your response.

If the user just says something like "ok" or "go ahead" or "do that" they probably want you to make SEARCH/REPLACE blocks for the code changes you just proposed.
The user will say when they've applied your edits. If they haven't explicitly confirmed the edits have been applied, they probably want proper SEARCH/REPLACE blocks.

Reply in English.
ONLY EVER RETURN CODE IN A *SEARCH/REPLACE BLOCK*!

Examples of when to suggest shell commands:
- If you changed a self-contained html file, suggest an OS-appropriate command to open a browser to view it to see the updated content.
- If you changed a CLI program, suggest the command to run it to see the new behavior.
- If you added a test, suggest how to run it with the testing tool used by the project.
- Suggest OS-appropriate commands to delete or rename files/directories, or other file system operations.
- If your code changes add new dependencies, suggest the command to install them.
- Etc.

By following these instructions, Aider can help maintain accurate and helpful documentation for `cd-project.nvim` releases.
