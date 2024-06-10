local json = require("cd-project.json")
---@class CdProject.Project
---@field path string
---@field name string
---@field desc string|nil

---@return CdProject.Project[]
local get_projects = function()
  return json.read_or_init_json_file(vim.g.cd_project_config.projects_config_filepath)
end

---@param projects CdProject.Project[]
local write_projects = function(projects)
  json.write_json_file(projects, vim.g.cd_project_config.projects_config_filepath)
end

return {
  get_projects = get_projects,
  write_projects = write_projects,
}
