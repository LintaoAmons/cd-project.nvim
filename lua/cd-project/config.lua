---@alias CdProject.Adapter "telescope"|"vim-ui"

---@class CdProject.Config
---@field projects_config_filepath string
---@field project_dir_pattern string[]
---@field hooks? CdProject.Hook[]
---@field project_peeker? CdProject.Adapter

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
	projects_picker = "vim-ui", -- optional, you can switch to `telescope`
}

local M = {}

---@type CdProject.Config
vim.g.cd_project_config = default_config

---@param user_config? CdProject.Config
M.setup = function(user_config)
	local previous_config = vim.g.cd_project_config or default_config
	vim.g.cd_project_config = vim.tbl_deep_extend("force", previous_config, user_config or {}) or default_config
end

return M
