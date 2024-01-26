local function cd_project()
	local adapter = vim.g.cd_project_config.adapter
	if adapter == "telescope" then
		return require("cd-project.adapter.telescope").cd_project()
	end

	require("cd-project.adapter.vim-ui").cd_project()
end

return {
	cd_project = cd_project,
}
