local project = require("cd-project.project-repo")
local api = require("cd-project.api")

---@param opts? table
local cd_project = function(opts)
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
					api.cd_project(selected_project.path)
				end)
				return true
			end,
			prompt_title = "cd to project",
			finder = finders.new_table({
				results = project.get_projects(),
				---@param project_entry CdProject.Project
				entry_maker = function(project_entry)
					return {
						value = project_entry,
						display = project_entry.path,
						ordinal = project_entry.path,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

return {
	cd_project = cd_project,
}
