# cd-project.nvim

I tried quite a lot `Project Management` plugins.

In the end,

I found all I need is an easier way to `cd` to another project directory.

## How it works?

This plugin did nothing but provide a simpler way to add, persist and switch to directories.

![HowItWorks](https://github.com/LintaoAmons/cd-project.nvim/assets/95092244/6fa66d86-38c0-4ea8-ad5e-a6ed14c263ef)

## Install and Config

- Work out of box with default config

```lua
-- using lazy.nvim
return {
  "LintaoAmons/cd-project.nvim",
  tag = "v0.11.0", -- Optional, You can use pin to a tag for stability
}
```

- Or, you want to customise the behaviour

```lua
---@type CdProject.Config
local opts = {
  -- this json file is acting like a database to update and read the projects in real time.
  -- So because it's just a json file, you can edit directly to add more paths you want manually
  projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
  -- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
  project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
  choice_format = "both",        -- optional, you can switch to "name" or "path"
  projects_picker = "telescope", -- optional, you can switch to `vim-ui`
  auto_register_project = false, -- optional, toggle on/off the auto add project behaviour
  -- do whatever you like by hooks
  hooks = {
    {
      callback = function(dir)
        vim.notify("switched to dir: " .. dir)
      end,
    },
    {
      callback = function(dir)
        vim.notify("switched to dir: " .. dir)
      end,                         -- required, action when trigger the hook
      name = "cd hint",            -- optional
      order = 1,                   -- optional, the exection order if there're multiple hooks to be trigger at one point
      pattern = "cd-project.nvim", -- optional, trigger hook if contains pattern
      trigger_point = "DISABLE",   -- optional, enum of trigger_points, default to `AFTER_CD`
      match_rule = function(dir)   -- optional, a function return bool. if have this fields, then pattern will be ignored
        return true
      end,
    },
  }
}

return {
    "LintaoAmons/cd-project.nvim",
    tag = "v0.10.0", -- Optional, You can also use tag to pin the plugin version for stability
    init = function() -- use init if you want enable auto_register_project, otherwise config is good
      require("cd-project").setup(opts)
    end,
  }
```

> [Hook examples](./HOOK_EXAMPLES.md)

## Commands and Workflow

| Command              | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| `CdProject`          | change working directory                                                    |
| `CdProjectAdd`       | add current project's directory to the database(json file)                  |
| `CdProjectBack`      | quickly switch between current project and previous project                 |
| `CdProjectManualAdd` | Manually add a path and optionally give it a name                           |
| `CdSearchAndAdd`     | fuzzy find directories in $HOME using telescope and optional give it a name |

## Default Picker Keymaps

| Map     | Action                               |
| ------- | ------------------------------------ |
| `<cr>`  | `cd` into project                    |
| `<c-t>` | `tcd` into project (open in new tab) |
| `<c-e>` | `lcd` into project (open in window)  |
| `<c-d>` | Delete project                       |
| `<c-r>` | Rename project                       |

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

By [telegram](https://t.me/+ssgpiHyY9580ZWFl) or [微信: CateFat](https://lintao-index.pages.dev/assets/images/wechat-437d6c12efa9f89bab63c7fe07ce1927.png)

## Self-Promotion

- [my website](https://oatnil.top)
- [my neovim config](https://github.com/LintaoAmons/VimEverywhere/tree/main/nvim)
- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [context-menu.nvim](https://github.com/LintaoAmons/context-menu.nvim)

<a href="https://www.buymeacoffee.com/lintaoamond" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
