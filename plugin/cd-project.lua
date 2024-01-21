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
local api = require("cd-project.api")

vim.api.nvim_create_user_command("CdProject", api.cd_project, {})
vim.api.nvim_create_user_command("CdProjectAdd", api.add_current_project, {})
