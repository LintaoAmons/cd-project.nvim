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

-- vague2k: We *could* check for the "find" command but then we would need to format
-- the telescope picker, which can lead to uneeded complexity.
--
-- I feel like not checking for "find" is a worthy trade off
--
-- TODO: Test on windows and mac. I'm 98% sure fd handles path string formatting
local check_for_find_cmd = function()
	-- if unix like system
	if package.config:sub(1, 1) == "/" then
		-- list of directories that should be excluded, that fill 1 of these 2 criteria
		-- 1. Is reasonably unlikely that a user will not have a project worth adding in the directory
		-- 2. Causes unreasonable hang times in executing command
		-- a prime example would be the hidden "/Library" dir on macOS systems.
		local find_command = (function()
			if 1 == vim.fn.executable("fd") then
				return "fd --type d --hidden -E Library -E .local -E .cache . ~"
			elseif 1 == vim.fn.executable("fdfind") then
				return "fdfind --type d --hidden -E Library -E .local -E .cache . ~"
			end
		end)()
		return find_command
	end

	-- any system that isn't unix like
	local find_command = (function()
		if 1 == vim.fn.executable("fd") then
			return { "fd", "--type", "d", "--color", "never" }
		elseif 1 == vim.fn.executable("fdfind") then
			return { "fdfind", "--type", "d", "--color", "never" }
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
