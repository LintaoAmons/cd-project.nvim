local utils = require("cd-project.utils")
local api = require("cd-project.api")
local repo = require("cd-project.project-repo")

---@param opts? table
local function cd_project(opts)
	opts = opts or {}
	local projects = repo.get_projects()

	local maxLength = 0
	for _, project in ipairs(projects) do
		if #project.name > maxLength then
			maxLength = #project.name
		end
	end

	vim.ui.select(projects, {
		prompt = "Select a directory",
		format_item = function(project)
			return utils.format_entry(project, maxLength)
		end,
	}, function(selected)
		if not selected then
			return utils.log_error("Must select a valid dir")
		end
		api.cd_project(selected.path)
	end)
end

local function manual_cd_project()
	-- TODO: needs error handling, but works as intended
	vim.ui.input({ prompt = "Add a project path: " }, function(path)
		if not path or path == "" then
			utils.log_error("No path given, quitting.")
			return
		end

		local final_path
		final_path = path

		vim.ui.input({ prompt = "Add a project name: " }, function(name)
			if not name then
				utils.log_error("Quit command from name input, dir was not added")
				return
			end

			if name == "" then
				vim.notify('No name given, using "' .. utils.get_tail_of_path(final_path) .. '" instead')
				api.add_project(final_path)
				return
			end

			local final_name
			final_name = name

			api.add_project(final_path, final_name)
		end)
	end)
end

return {
	cd_project = cd_project,
	manual_cd_project = manual_cd_project,
}
