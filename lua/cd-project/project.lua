local json = require("cd-project.json")
---@class CdProject.Project
---@field path string
---@field name string
---@field desc string|nil

local M = {}

---@param projects_config_filepath string
---@return CdProject.Project[]
M.get_projects = function(projects_config_filepath)
	return json.read_or_init_json_file(projects_config_filepath)
end

---@param projects CdProject.Project[]
---@param projects_config_filepath string
M.write_projects = function(projects, projects_config_filepath)
	json.write_json_file(projects, projects_config_filepath)
end

return M
