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

local function cd_project()
	vim.ui.select(config.get_projects(), {
		prompt = "Select a directory",
	}, function(dir)
		if not dir then
			return logErr("Must select a valid dir")
		end
		vim.cmd("cd " .. dir)
		vim.notify("switched to dir: " .. dir)
	end)
end

local function add_current_project()
	local project_dir = find_project_dir()
	if not project_dir then
		return logErr("Can't find project path of current file")
	end

	config.add_project(project_dir)
end

return {
	cd_project = cd_project,
	add_current_project = add_current_project,
}
