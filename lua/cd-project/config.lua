local usercommands = require("cd-project.usercommands")
local api = require("cd-project.api")

---@alias CdProject.Adapter "telescope"|"vim-ui"

---@class CdProject.Config
---@field projects_config_filepath string
---@field project_dir_pattern string[]
---@field hooks? CdProject.Hook[]
---@field adapter? CdProject.Adapter

---@type CdProject.Config
local default_config = {
	-- this json file is acting like a database to update and read the projects in real time.
	-- So because it's just a json file, you can edit directly to add more paths you want manually
	projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
	-- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
	project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
	hooks = {
		{
			callback = function(dir)
				vim.notify("switched to dir: " .. dir)
			end,
		},
		{
			callback = function(dir)
				vim.notify("switched to dir: " .. dir)
			end, -- required, action when trigger the hook
			name = "cd hint", -- optional
			order = 1, -- optional, the exection order if there're multiple hooks to be trigger at one point
			pattern = "cd-project.nvim", -- trigger hook if contains pattern, optional
			trigger_point = "DISABLE", -- enum of trigger_points, optional, default to `AFTER_CD`
			match_rule = function(dir) -- optional, a function return bool. if have this fields, then pattern will be ignored
				return true
			end,
		},
	},
	adapter = "telescope",
}

local M = {
	config = default_config,
}

---@param user_config? CdProject.Config
M.setup = function(user_config)
	M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
	vim.g.cd_project_current_project = api.find_project_dir(M.config)
	usercommands.setup(M.config)
end

return M
