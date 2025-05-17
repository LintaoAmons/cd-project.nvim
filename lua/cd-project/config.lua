---@alias CdProject.Adapter "telescope"|"vim-ui"
---@alias CdProject.ChoiceFormat "name"|"path"|"both"

---@class CdProject.Config
---@field projects_config_filepath string
---@field project_dir_pattern string[]
---@field choice_format? CdProject.ChoiceFormat
---@field projects_picker? CdProject.Adapter
---@field hooks? CdProject.Hook[]
---@field format_json? boolean

---@type CdProject.Config
local default_config = require("cd-project.default-config")

local M = {}

---@type CdProject.Config
vim.g.cd_project_config = default_config

---@param user_config? CdProject.Config
M.setup = function(user_config)
  local previous_config = vim.g.cd_project_config or default_config
  vim.g.cd_project_config = vim.tbl_deep_extend("force", previous_config, user_config or {}) or default_config
  if vim.g.cd_project_config.auto_register_project then
    require("cd-project.auto").setup()
  else
    require("cd-project.auto").clear()
  end
end

return M
