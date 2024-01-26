local utils = require("cd-project.utils")
local api = require("cd-project.api")
local projects_repo = require("cd-project.project-repo")

---@param opts? table
local function cd_project(opts)
	opts = opts or {}
	-- Determine whether to show project names or paths
	local api_func
	local show_project_names = vim.g.cd_project_config.show_project_names
	if show_project_names == true then
		api_func = api.get_project_names()
	else
		api_func = api.get_project_paths()
	end

	vim.ui.select(api_func, {
		prompt = "Select a directory",
	}, function(selected)
		if not selected then
			return utils.log_error("Must select a valid dir")
		end

		--[[HACK:
        --  vague2k: A list of names is passed to vim.ui.select() based on the choice (name)
        --  we loop through the array of projects and check if the project's name at that index
        --  matches the option that was chosen. 
        --  If it matches assign the projects path to selected_dir and break the loop.
        --]]

		if show_project_names == true then
			local projects = projects_repo.get_projects()
			local selected_dir
			for _, project in ipairs(projects) do
				if project.name == selected then
					selected_dir = project.path
					break
				end
			end
			api.cd_project(selected_dir)
		else
			-- If showing project paths, use the selected path directly
			api.cd_project(selected)
		end
	end)
end

return {
	cd_project = cd_project,
}
