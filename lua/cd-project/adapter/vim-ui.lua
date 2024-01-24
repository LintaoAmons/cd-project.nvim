local api = require("cd-project.api")
local function logErr(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

-- TODO: how to make this level purely to get user input and pass to the api functions
--
---@param config CdProject.Config
local function cd_project(config)
	vim.ui.select(api.get_project_paths(config.projects_config_filepath), {
		prompt = "Select a directory",
	}, function(dir)
		if not dir then
			return logErr("Must select a valid dir")
		end
		api.cd_project(config.hooks, dir)
	end)
end

return {
	cd_project = cd_project,
}
