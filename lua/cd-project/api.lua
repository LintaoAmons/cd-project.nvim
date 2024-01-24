local cd_hooks = require("cd-project.hooks")
local project = require("cd-project.project")

local function logErr(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@param user_config CdProject.Config
---@return string|nil
function find_project_dir(user_config)
	local found = vim.fs.find(
		user_config.project_dir_pattern,
		{ upward = true, stop = vim.loop.os_homedir(), path = vim.fs.dirname(vim.fn.expand("%:p")) }
	)

	if #found == 0 then
		return vim.loop.os_homedir()
	end

	local project_dir = vim.fs.dirname(found[1])

	if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
		project_dir = string.match(vim.fn.execute("pwd"), "^%s*(.-)%s*$")
	end

	if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
		return nil
	end

	return project_dir
end

---@param projects_config_filepath string
---@return string[]
local function get_project_paths(projects_config_filepath)
	local projects = project.get_projects(projects_config_filepath)
	local paths = {}
	for _, value in ipairs(projects) do
		table.insert(paths, value.path)
	end
	return paths
end

---@param config_hooks CdProject.Hook[]
---@param dir string
local function cd_project(config_hooks, dir)
	vim.g.cd_project_last_project = vim.g.cd_project_current_project
	vim.g.cd_project_current_project = dir
	vim.fn.execute("cd " .. dir)

	local hooks = cd_hooks.get_hooks(config_hooks, dir, "AFTER_CD")
	for _, hook in ipairs(hooks) do
		hook(dir)
	end
end

---@param user_config CdProject.Config
local function add_current_project(user_config)
	local project_dir = find_project_dir(user_config)

	if not project_dir then
		return logErr("Can't find project path of current file")
	end

	local projects = project.get_projects(user_config.projects_config_filepath)

	if vim.tbl_contains(get_project_paths(user_config.projects_config_filepath), project_dir) then
		return vim.notify("Project already exists: " .. project_dir)
	end

	local new_project = {
		path = project_dir,
		name = "name place holder", -- TODO: allow user to edit the name of the project
	}
	table.insert(projects, new_project)
	project.write_projects(projects, user_config.projects_config_filepath)
	vim.notify("Project added: \n" .. project_dir)
end

---@param config_hooks CdProject.Hook[]
local function back(config_hooks)
	local last_project = vim.g.cd_project_last_project
	if not last_project then
		vim.notify("Can't find last project. Haven't switch project yet.")
	end
	cd_project(config_hooks, last_project)
end

return {
	cd_project = cd_project,
	add_current_project = add_current_project,
	get_project_paths = get_project_paths,
	back = back,
	find_project_dir = find_project_dir,
}
