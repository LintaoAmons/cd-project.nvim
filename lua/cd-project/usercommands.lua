local api = require("cd-project.api")
local telescope = require("cd-project.adapter.telescope")
local vim_ui = require("cd-project.adapter.vim-ui")
local M = {}

---@param adapter CdProject.Adapter
local function get_cd_project_callback(adapter)
	if adapter == "telescope" then
		return telescope.cd_project
	end
	if adapter == "vim-ui" then
		return vim_ui.cd_project
	end
end

---@param config CdProject.Config
M.setup = function(config)
	local cd_project = get_cd_project_callback(config.adapter)
	vim.api.nvim_create_user_command("CdProject", function()
		cd_project(config)
	end, {})
	vim.api.nvim_create_user_command("CdProjectAdd", function()
		api.add_current_project(config)
	end, {})
	vim.api.nvim_create_user_command("CdProjectBack", function()
		api.back(config.hooks)
	end, {})
end

return M
