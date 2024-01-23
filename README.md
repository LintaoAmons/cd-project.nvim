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
        projects_config_filepath = vim.fs.normalize(
          vim.fn.stdpath("config") .. "/cd-project.nvim.json"
        ),
        -- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
        project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
      })
    end,
  }
```

## Commands and Apis

| Command         | Description                                                 |
|-----------------|-------------------------------------------------------------|
| `CdProject`     | change working directory                                    |
| `CdProjectAdd`  | add current project's directory to the database(json file)  |
| `CdProjectBack` | quickly switch between current project and previous project |


You can call the Apis provided by the plugin, to integrate into your own work flow

```lua
require("cd-project.api").some_method()
```

you can find the exported Apis at [./lua/cd-project/api.lua](./lua/cd-project/api.lua)


## FIND MORE UESR FRIENDLY PLUGINS MADE BY ME

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [easy-commands.nvim](https://github.com/LintaoAmons/easy-commands.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
