# cd-project.nvim

I tried quite a lot `Project Management` plugins.

In the end,

I found all I need is an easier way to `cd` to another project directory.

## How it works?

This plugin did nothing but provide a simpler way to add, persist and switch to directories.

![HowItWorks](https://github.com/LintaoAmons/cd-project.nvim/assets/95092244/6fa66d86-38c0-4ea8-ad5e-a6ed14c263ef)

## Install and Config

- Simple version

```lua
-- using lazy.nvim
return { "LintaoAmons/cd-project.nvim" }
```

- All config options

```lua
-- using lazy.nvim
return {
    "LintaoAmons/cd-project.nvim",
    -- Don't need call the setup function if you think you are good with the default configuration
    tag = "v0.10.0", -- Optional, You can also use tag to pin the plugin version for stability
    init = function() -- use init if you want enable auto_register_project, otherwise config is good
      require("cd-project").setup({
        -- this json file is acting like a database to update and read the projects in real time.
        -- So because it's just a json file, you can edit directly to add more paths you want manually
        projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
        -- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
        project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
        choice_format = "both", -- optional, you can switch to "name" or "path"
        projects_picker = "telescope", -- optional, you can switch to `telescope`
        auto_register_project = false, -- optional, toggle on/off the auto add project behaviour
        -- do whatever you like by hooks
        hooks = {
          -- Run before cd to project, add a bookmark here, then can use `CdProjectBack` to switch back
          -- {
          --   trigger_point = "BEFORE_CD",
          --   callback = function(_)
          --     vim.print("before cd project")
          --     require("bookmarks").api.mark({name = "before cd project"})
          --   end,
          -- },
          -- Run after cd to project, find and open a file in the target project by smart-open
          -- {
          --   callback = function(_)
          --     require("telescope").extensions.smart_open.smart_open({
          --       cwd_only = true,
          --       filename_first = false,
          --     })
          --   end,
          -- },
        }
      })
    end,
  }
```

> [Hook examples](./HOOK_EXAMPLES.md)

## Commands and Workflow

| Command              | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| `CdProject`          | change working directory                                                    |
| `CdProjectTab`       | change working directory in tab (or you can use `<c-o>` when `CdProject`)   |
| `CdProjectAdd`       | add current project's directory to the database(json file)                  |
| `CdProjectBack`      | quickly switch between current project and previous project                 |
| `CdProjectManualAdd` | Manually add a path and optionally give it a name                           |
| `CdSearchAndAdd`     | fuzzy find directories in $HOME using telescope and optional give it a name |

### Workflow

1. Add a project into `cd-project.nvim`: `CdProjectAdd`
2. switch to the project: `CdProject`
   1. `<CR>` will go to the project, change current working directory to the project
   2. `AFTER_CD` hook will be triggered, I use it to open a file in the project by `smart-open`
   3. Or in the telescope picker, you can use `<c-o>` to open a project in a new tab, or switch to that project's tab if it's already opened
      - Usecase: Open multiple projects can jump between them
   4. Or in the telescope picker, you can use `<c-e>` to trigger the hooks but without change the current working directory.
      - Usecase: You just want to open a file in that project in a split window, but don't want to change the current working directory.

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

By [telegram](https://t.me/+ssgpiHyY9580ZWFl) or [微信: CateFat](https://lintao-index.pages.dev/assets/images/wechat-437d6c12efa9f89bab63c7fe07ce1927.png)

## Some Other Neovim Stuff

- [my neovim config](https://github.com/LintaoAmons/CoolStuffes/tree/main/nvim/.config/nvim)
- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [context-menu.nvim](https://github.com/LintaoAmons/context-menu.nvim)
