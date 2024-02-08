---@param msg string
local function log_error(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@param path string
local function get_tail_of_path(path)
	-- Remove leading directories, keep the last part
	local tail = path:match("([^/]+)$")
	local parent = path:match("^.*%/([^/]+)/?$") -- Get the parent directory
	-- if foo/ return bar
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

return {
	log_error = log_error,
	get_tail_of_path = get_tail_of_path,
	format_entry = format_entry,
	check_for_find_cmd = check_for_find_cmd,
}
