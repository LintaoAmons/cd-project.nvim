local api = require("cd-project.api")
local function setup()
	local auto_group_name = "CdProjectPlugin"

	vim.api.nvim_create_augroup(auto_group_name, { clear = true })
	vim.api.nvim_create_autocmd({ "VimEnter" }, {
		group = auto_group_name,
		callback = function(_)
			api.add_current_project()
      vim.print("method called")
		end,
	})
end

return {
	auto_register_project_setup = setup,
}
