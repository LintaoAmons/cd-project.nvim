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
local action_set = require("telescope.actions.set")

local repo = require("cd-project.project-repo")
local api = require("cd-project.api")

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

local manual_cd_project = function(opts)
	opts = opts or {}

	-- TODO: test on windows, most likely does not because windows is dookie and wants
	-- to be different SOOO bad
	--
	-- most likely will need to handle how cwd property in jobstart is handled for windows... %USERPROFILE% ???

	-- check if the find or fd command exists on the users system
	local find_command = utils.check_for_find_cmd()
	if not find_command then
		utils.log_error("You need to install fd or find.")
		return
	end

	-- Harding coding the Home directory as a starting point for finding
	-- directories is desireable since it's very unlikely a user will have
	-- a project worth adding to the cd list in any parent dir relative to the home dir.
	vim.fn.jobstart(find_command, {
		cwd = vim.fn.expand("~"),
		stdout_buffered = true,
		on_stdout = function(_, data)
			pickers
				.new(opts, {
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selected_dir = action_state.get_selected_entry().value
							local formatted_path = vim.fn.expand("~") .. "/" .. selected_dir

							-- TODO: using vim.ui for name input feels hacky...
							-- if there's a way to use telescope instead of vim.ui for this, that would be preferred
							vim.ui.input({ prompt = "Add a project name: " }, function(name)
								if not name then
									utils.log_error("Quit command from name input, dir was not added")
									return
								end

								if name == "" then
									vim.notify(
										'No name given, using "'
											.. utils.get_tail_of_path(formatted_path)
											.. '" instead'
									)
									api.add_project(formatted_path)
									return
								end

								api.add_project(formatted_path, name)
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

manual_cd_project()

return {
	cd_project = cd_project,
	manual_cd_project = manual_cd_project,
}
