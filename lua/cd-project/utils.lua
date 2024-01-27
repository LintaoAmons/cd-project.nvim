---@param msg string
local function log_error(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@param path string
local function get_tail_of_path(path)
	-- Remove leading directories, keep the last part
	return path:match("([^/]+)$")
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

return {
	log_error = log_error,
	get_tail_of_path = get_tail_of_path,
	format_entry = format_entry,
}
