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
    config = function()
      require("cd-project").setup({
        projects_config_filepath = vim.fs.normalize(
          vim.fn.stdpath("config") .. "/cd-project.nvim.json"
        ),
        project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
      })
    end,
  }
```


## FIND MORE UESR FRIENDLY PLUGIN MADE BY ME

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [easy-commands](https://github.com/LintaoAmons/easy-commands.nvim)
- [cd-project](https://github.com/LintaoAmons/cd-project.nvim)
