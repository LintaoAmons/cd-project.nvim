local M = {}

M.log_error = function(msg)
	vim.notify(msg, vim.log.levels.ERROR, { title = "cd-project.nvim" })
end

return M
