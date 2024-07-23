# cd-project.nvim

I tried quite a lot `Project Management` plugins.

In the end,

I found all I need is an easier way to `cd` to another project directory.

## How it works?

This plugin did nothing but provide a simpler way to add, persist and switch to directories.

![HowItWorks](https://github.com/LintaoAmons/cd-project.nvim/assets/95092244/6fa66d86-38c0-4ea8-ad5e-a6ed14c263ef)

## Install and Config
> My config as ref: https://github.com/LintaoAmons/dotfiles/blob/master/nvim/.config/nvim/lua/plugins/editor/project.lua

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
    tag = "v0.6.1", -- Optional, You can also use tag to pin the plugin version for stability
    config = function()
      require("cd-project").setup({
        -- this json file is acting like a database to update and read the projects in real time.
        -- So because it's just a json file, you can edit directly to add more paths you want manually
        projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
        -- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
        project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
        choice_format = "both", -- optional, you can switch to "name" or "path"
        projects_picker = "vim-ui", -- optional, you can switch to `telescope`
        auto_register_project = false, -- optional, toggle on/off the auto add project behaviour
        -- do whatever you like by hooks
        hooks = {
          {
            callback = function(dir)
              vim.notify("switched to dir: " .. dir)
            end,
          },
          {
            callback = function(_)
              vim.cmd("Telescope find_files")
            end,
          },
          {
            callback = function(dir)
              vim.notify("switched to dir: " .. dir)
            end, -- required, action when trigger the hook
            name = "cd hint", -- optional
            order = 1, -- optional, the exection order if there're multiple hooks to be trigger at one point
            pattern = "cd-project.nvim", -- optional, trigger hook if contains pattern
            trigger_point = "DISABLE", -- optional, enum of trigger_points, default to `AFTER_CD`
            match_rule = function(dir) -- optional, a function return bool. if have this fields, then pattern will be ignored
              return true
            end,
          },
        } 
      })
    end,
  }
```

> [Hook examples](./HOOK_EXAMPLES.md)

## Commands and Apis

| Command              | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| `CdProject`          | change working directory                                                    |
| `CdProjectTab`       | change working directory in tab                                             |
| `CdProjectAdd`       | add current project's directory to the database(json file)                  |
| `CdProjectBack`      | quickly switch between current project and previous project                 |
| `CdProjectManualAdd` | Manually add a path and optionally give it a name                           |
| `CdSearchAndAdd`     | fuzzy find directories in $HOME using telescope and optional give it a name |

You can call the Apis provided by the plugin, to integrate into your own work flow

```lua
require("cd-project.api").some_method()
```

you can find the exported Apis at [./lua/cd-project/api.lua](./lua/cd-project/api.lua)

- [ ] Remember the buffer and cursor location while switch to the project

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

By [telegram](https://t.me/+ssgpiHyY9580ZWFl) or [微信: CateFat](https://lintao-index.pages.dev/assets/images/wechat-437d6c12efa9f89bab63c7fe07ce1927.png)

## Some Other Neovim Stuff

- [my neovim config](https://github.com/LintaoAmons/CoolStuffes/tree/main/nvim/.config/nvim)
- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [context-menu.nvim](https://github.com/LintaoAmons/context-menu.nvim)

