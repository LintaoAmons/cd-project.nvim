local telescope = require("cd-project.adapter.telescope")
local vim_ui = require("cd-project.adapter.vim-ui")
local api = require("cd-project.api")

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
	vim.g.cd_project_current_project = api.find_project_dir()
	local cd_project = get_cd_project_callback(config.adapter)
	vim.api.nvim_create_user_command("CdProject", function()
		cd_project()
	end, {})
	vim.api.nvim_create_user_command("CdProjectAdd", function()
		api.add_current_project()
	end, {})
	vim.api.nvim_create_user_command("CdProjectBack", function()
		api.back()
	end, {})
end

return M
