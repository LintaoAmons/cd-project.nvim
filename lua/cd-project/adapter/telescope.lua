local project = require("cd-project.project")
local api = require("cd-project.api")

local M = {}

---@param config CdProject.Config
---@param opts table
M.cd_project = function(config, opts)
	local utils = require("cd-project.utils")
	local success, picker = pcall(require, "telescope.pickers")
	if not success then
		utils.log_error("telescope not installed")
		return
	end
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	opts = opts or {}
	pickers
		.new(opts, {
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					---@type CdProject.Project
					local selected_project = action_state.get_selected_entry().value
					print("selected_project", vim.inspect(selected_project))
					api.cd_project(config.hooks, selected_project.path)
				end)
				return true
			end,
			prompt_title = "cd to project",
			finder = finders.new_table({
				results = project.get_projects(config.projects_config_filepath),
				---@param project_entry CdProject.Project
				entry_maker = function(project_entry)
					return {
						value = project_entry,
						display = project_entry.name,
						ordinal = project_entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

return M
