> Note: `v0.3.0` displays name in project picker. before this version, the default name is `name place holder`, you can edit the json file directly to change it to a more meaningful name. Or only display the path of the projects you added by modify the `choice_format` option in the config.

# cd-project.nvim

I tried quite a lot `Project Management` plugins.

In the end,

I found all I need is an easier way to `cd` to another project directory.

## How it works?

This plugin did nothing but provided a simplier way to add and switch to directories

![HowItWorks](https://github.com/LintaoAmons/cd-project.nvim/assets/95092244/6fa66d86-38c0-4ea8-ad5e-a6ed14c263ef)

## Install and Config

```lua
-- using lazy.nvim
return {
    "LintaoAmons/cd-project.nvim",
    -- Don't need call the setup function if you think you are good with the default configuration
    config = function()
      require("cd-project").setup({
        -- this json file is acting like a database to update and read the projects in real time.
        -- So because it's just a json file, you can edit directly to add more paths you want manually
        projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
        -- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
        project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
        choice_format = "both", -- optional, you can switch to "name" or "path"
        projects_picker = "vim-ui", -- optional, you can switch to `telescope`
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
        },
      })
    end,
  }
```

> [Hook examples](./HOOK_EXAMPLES.md)

## Commands and Apis

| Command              | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| `CdProject`          | change working directory                                                    |
| `CdProjectAdd`       | add current project's directory to the database(json file)                  |
| `CdProjectBack`      | quickly switch between current project and previous project                 |
| `CdProjectManualAdd` | Manually add a path and optionally give it a name                           |
| `CdSearchAndAdd`     | fuzzy find directories in $HOME using telescope and optional give it a name |

You can call the Apis provided by the plugin, to integrate into your own work flow

```lua
require("cd-project.api").some_method()
```

you can find the exported Apis at [./lua/cd-project/api.lua](./lua/cd-project/api.lua)

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

You can contact with me by drop me an email or [telegram](https://t.me/+ssgpiHyY9580ZWFl)

## FIND MORE USER FRIENDLY PLUGINS MADE BY ME

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [easy-commands.nvim](https://github.com/LintaoAmons/easy-commands.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [plugin-template.nvim](https://github.com/LintaoAmons/plugin-template.nvim)
