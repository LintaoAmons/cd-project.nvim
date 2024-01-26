local M = {}

---@param msg string
local function log_error(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

---@param path string
local function get_tail_of_path(path)
	-- Remove leading directories, keep the last part
	return path:match("([^/]+)$")
end

return {
	log_error = log_error,
	get_tail_of_path = get_tail_of_path,
}
