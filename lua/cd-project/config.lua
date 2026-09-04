---@alias CdProject.Adapter "telescope"|"vim-ui"|"snacks"
---@alias CdProject.ChoiceFormat "name"|"path"|"both"
-- What `search_project` looks for inside a project. An enum string rather than a
-- boolean pair so a third mode can be added later without touching existing calls.
---@alias CdProject.SearchKind "files"|"grep"

---@class CdProject.Config
---@field projects_config_filepath string
---@field project_dir_pattern string[]
---@field choice_format? CdProject.ChoiceFormat
---@field projects_picker? CdProject.Adapter
---@field hooks? CdProject.Hook[]
---@field format_json? boolean
---@field remember_project_position? boolean

---@type CdProject.Config
local default_config = require("cd-project.default-config")

local M = {}

---@type CdProject.Config
vim.g.cd_project_config = default_config

---@param user_config? CdProject.Config
M.setup = function(user_config)
  user_config = user_config or {}
  local previous_config = vim.g.cd_project_config or default_config
  local merged = vim.tbl_deep_extend("force", previous_config, user_config)
  -- hooks is a list: replace it wholesale instead of deep-merging by index,
  -- otherwise user hooks get mixed with leftover default hooks
  if user_config.hooks then
    merged.hooks = user_config.hooks
  end
  vim.g.cd_project_config = merged
  if vim.g.cd_project_config.auto_register_project then
    require("cd-project.auto").setup()
  else
    require("cd-project.auto").clear()
  end
  
  -- Initialize position tracking
  require("cd-project.position").setup()
end

return M
