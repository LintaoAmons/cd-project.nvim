-- TODO: refator to picker

local function cd_project()
	local projects_picker = vim.g.cd_project_config.projects_picker
	if projects_picker == "telescope" then
		return require("cd-project.adapter.telescope").cd_project()
	end

	require("cd-project.adapter.vim-ui").cd_project()
end

local function manual_cd_project()
	require("cd-project.adapter.vim-ui").manual_cd_project()
end

local function telescope_search_and_add()
	local projects_picker = vim.g.cd_project_config.projects_picker
	if projects_picker == "telescope" then
		return require("cd-project.adapter.telescope").search_and_add()
	end
end

return {
	cd_project = cd_project,
	manual_cd_project = manual_cd_project,
	telescope_search_and_add = telescope_search_and_add,
}
