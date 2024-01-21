---@class CdProject.Config
---@field projects_config_filepath string
---@field project_dir_pattern string[]

---@type CdProject.Config
local default_config = {
	projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
	project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
}

local M = {
	config = default_config,
}

---@param user_config? CdProject.Config
M.setup = function(user_config)
	M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

---@param tbl table
---@param path string
local write_json_file = function(tbl, path)
	local content = vim.fn.json_encode(tbl) -- Encoding table to JSON string

	local file, err = io.open(path, "w")
	if not file then
		error("Could not open file: " .. err)
		return nil
	end

	file:write(content)
	file:close()
end

---@param path string
---@return table
local read_or_init_json_file = function(path)
	local file, _ = io.open(path, "r")
	if not file then
		write_json_file({}, path)
		return {}
	end

	local content = file:read("*a") -- Read the entire content
	file:close()

	return vim.fn.json_decode(content) or {}
end

---@return CdProject.Project[]
M.get_projects = function()
	return read_or_init_json_file(M.config.projects_config_filepath)
end

---@param projects CdProject.Project[]
M.write_projects = function(projects)
	write_json_file(projects, M.config.projects_config_filepath)
end

return M
