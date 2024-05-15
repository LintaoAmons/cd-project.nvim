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

local repo = require("cd-project.project-repo")
local api = require("cd-project.api")

---@param callback fun(project: CdProject.Project): nil
---@param opts? table
local function project_picker(callback, opts)
	opts = opts or {}
	-- TODO: a format function
	local projects = repo.get_projects()
	local maxLength = 0
	for _, project in ipairs(projects) do
		if #project.name > maxLength then
			maxLength = #project.name
		end
	end

	pickers
		.new(opts, {
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					---@type CdProject.Project
					local selected_project = action_state.get_selected_entry().value
					callback(selected_project)
				end)
				return true
			end,
			prompt_title = "[CdProject]",
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

---@param opts? table
local cd_project = function(opts)
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
			attach_mappings = function(prompt_bufnr)
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

local search_and_add = function(opts)
	opts = opts or {}

	local find_command = utils.check_for_find_cmd()
	if not find_command then
		utils.log_error("You need to install fd or find.")
		return
	end

	vim.fn.jobstart(find_command, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			pickers
				.new(opts, {
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selected_dir = action_state.get_selected_entry().value

							vim.ui.input({ prompt = "Add a project name: " }, function(name)
								if not name or name == "" then
									vim.notify(
										'No name given, using "' .. utils.get_tail_of_path(selected_dir) .. '" instead'
									)
									local project = api.build_project_obj(selected_dir)
									if not project then
										return
									end
									return api.add_project(project)
								end

								local project = api.build_project_obj(selected_dir, name)
								if not project then
									return
								end
								return api.add_project(project)
							end)
						end)
						return true
					end,
					prompt_title = "Select dir to add",
					finder = finders.new_table({
						results = data,
					}),
					sorter = conf.file_sorter(opts),
				})
				:find()
		end,
	})
end

return {
	cd_project = cd_project,
	search_and_add = search_and_add,
  project_picker = project_picker,
}
