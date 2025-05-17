if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("cd-project.nvim requires at least nvim-0.7")
  return
end

-- make sure this file is loaded only once
if vim.g.loaded_cd_project == 1 then
  return
end
vim.g.loaded_cd_project = 1

require("cd-project").setup()
local adapter = require("cd-project.adapter")
local api = require("cd-project.api")
vim.g.cd_project_current_project = api.find_project_dir()

vim.api.nvim_create_user_command("CdProject", adapter.cd_project, {})
vim.api.nvim_create_user_command("CdProjectAdd", function()
  api.add_current_project({ show_duplicate_hints = true })
end, {})
vim.api.nvim_create_user_command("CdProjectManualAdd", adapter.manual_cd_project, {})
vim.api.nvim_create_user_command("CdProjectSearchAndAdd", adapter.telescope_search_and_add, {})
vim.api.nvim_create_user_command("CdProjectDelete", adapter.delete_project, {})
vim.api.nvim_create_user_command("CdProjectBack", api.back, {})
