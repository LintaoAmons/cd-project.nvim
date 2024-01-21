local config = require("cd-project.config")
local function logErr(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@return string|nil
local function find_project_dir()
	local found = vim.fs.find(
		config.config.project_dir_pattern,
		{ upward = true, stop = vim.loop.os_homedir(), path = vim.fs.dirname(vim.fn.expand("%:p")) }
	)

	if #found == 0 then
		return vim.loop.os_homedir()
	end

	return vim.fs.dirname(found[1])
end

---@param projects CdProject.Project[]
---@return string[]
local function get_project_paths(projects)
	local paths = {}
	for _, value in ipairs(projects) do
		table.insert(paths, value.path)
	end
	return paths
end

local function cd_project()
	local projects = config.get_projects()
	vim.ui.select(get_project_paths(projects), {
		prompt = "Select a directory",
	}, function(dir)
		if not dir then
			return logErr("Must select a valid dir")
		end
		vim.fn.execute("cd " .. dir)
		vim.notify("switched to dir: " .. dir)
	end)
end

local function add_current_project()
	local project_dir = find_project_dir()

	if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
		project_dir = string.match(vim.fn.execute("pwd"), "^%s*(.-)%s*$")
	end

	if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
		return logErr("Can't find project path of current file")
	end

	local projects = config.get_projects()

	if vim.tbl_contains(get_project_paths(projects), project_dir) then
		return vim.notify("Project already exists: " .. project_dir)
	end

	local new_project = {
		path = project_dir,
		name = "name place holder", -- TODO: allow user to edit the name of the project
	}
	table.insert(projects, new_project)
	config.write_projects(projects)
	vim.notify("Project added: \n" .. project_dir)
end

return {
	cd_project = cd_project,
	add_current_project = add_current_project,
}
