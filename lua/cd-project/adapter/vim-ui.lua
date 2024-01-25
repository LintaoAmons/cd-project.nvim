local utils = require("cd-project.utils")
local api = require("cd-project.api")

-- TODO: how to make this level purely to get user input and pass to the api functions
--
local function cd_project()
	vim.ui.select(api.get_project_paths(), {
		prompt = "Select a directory",
	}, function(dir)
		if not dir then
			return utils.log_error("Must select a valid dir")
		end
		api.cd_project(dir)
	end)
end

return {
	cd_project = cd_project,
}
