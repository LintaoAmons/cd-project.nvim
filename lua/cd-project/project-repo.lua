local json = require("cd-project.json")
---@class CdProject.Project
---@field path string
---@field name string
---@field desc string|nil
---@field last_file string|nil Path to last opened file (relative to project root)
---@field last_position number[]|nil Cursor position as [line, col]

---@return CdProject.Project[]
local get_projects = function()
  local json = json.read_or_init_json_file(vim.g.cd_project_config.projects_config_filepath)

  -- Filter out projects whose directory does not exit
  local existing_projects = vim.tbl_filter(function(p)
    return vim.fn.isdirectory(p.path) == 1
  end, json)

  return existing_projects

end

---@param projects CdProject.Project[]
local write_projects = function(projects)
  json.write_json_file(projects, vim.g.cd_project_config.projects_config_filepath)
end

return {
  get_projects = get_projects,
  write_projects = write_projects,
}
