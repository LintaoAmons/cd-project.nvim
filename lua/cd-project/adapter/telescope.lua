local repo = require("cd-project.project-repo")
local api = require("cd-project.api")

---@param opts? table
local cd_project = function(opts)
	local utils = require("cd-project.utils")
	local success, _ = pcall(require, "telescope.pickers")
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
	local projects = repo.get_projects()
	local maxLength = 0
	for _, project in ipairs(projects) do
		if #project.name > maxLength then
			maxLength = #project.name
		end
	end

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
				results = projects,
				---@param project CdProject.Project
				entry_maker = function(project)
					return {
						value = project,
						display = utils.format_entry(project, maxLength),
						ordinal = project.path,
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
