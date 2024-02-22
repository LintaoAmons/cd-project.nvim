---@param msg string
local function log_error(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@param path string
local function get_tail_of_path(path)
	-- Remove leading directories, keep the last part
	local tail = path:match("([^/]+)$")
	local parent = path:match("^.*%/([^/]+)/?$") -- Get the parent directory
	-- if foo/ return foo
	if parent and not tail then
		return parent
	-- if foo/bar, return bar
	else
		return tail -- Return only the tail if there is no parent
	end
end

---@param project CdProject.Project
---@param max_len integer
local function format_entry(project, max_len)
	local format = vim.g.cd_project_config.choice_format
	if format == "name" then
		return project.name
	end
	if format == "path" then
		return project.path
	end
	return string.format("%-" .. max_len .. "s", project.name) .. "  |  " .. project.path
end

local check_for_find_cmd = function()
	local find_command = (function()
		if 1 == vim.fn.executable("fd") then
			return { "fd", "--type", "d", "--color", "never" }
		elseif 1 == vim.fn.executable("fdfind") then
			return { "fdfind", "--type", "d", "--color", "never" }
		elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
			return { "find", ".", "-type", "d" }
		end
	end)()
	return find_command
end

---@param path string
---@return string
-- should be used in the telescope adapter's manual_cd_project method
local function format_dir_based_on_os(path)
	-- the "before format" example belows are how paths are passed to api.add_project

	local is_mac = vim.loop.os_uname().sysname == "Darwin"
	-- local is_linux = vim.loop.os_uname().sysname == "Linux"
	local is_windows = vim.loop.os_uname().sysname:find("Windows") and true or false

	-- before format: /foo/barbuzz
	-- after format: /foo/bar/buzz
	if is_mac then
		return vim.fn.expand("~") .. "/" .. path
	end

	-- before format: C:\User\namepathname
	-- after format: C:\User\name\pathname
	if is_windows then
		return vim.fn.expand("~") .. "\\" .. path
	end

	-- Linux
	-- before format: ./foo/bar/buzz
	-- after format: /home/user/foo/bar/buzz
	local format_linux_path = path:gsub("^%./", vim.fn.expand("~") .. "/")
	return format_linux_path
end

return {
	log_error = log_error,
	get_tail_of_path = get_tail_of_path,
	format_entry = format_entry,
	check_for_find_cmd = check_for_find_cmd,
	format_dir_based_on_os = format_dir_based_on_os,
}
