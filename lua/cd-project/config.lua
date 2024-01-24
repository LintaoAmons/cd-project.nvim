---@class CdProject.Config
---@field projects_config_filepath string
---@field project_dir_pattern string[]

---@type CdProject.Config
local default_config = {
	-- this json file is acting like a database to update and read the projects in real time.
	-- So because it's just a json file, you can edit directly to add more paths you want manually
	projects_config_filepath = vim.fs.normalize(vim.fn.stdpath("config") .. "/cd-project.nvim.json"),
	-- this controls the behaviour of `CdProjectAdd` command about how to get the project directory
	project_dir_pattern = { ".git", ".gitignore", "Cargo.toml", "package.json", "go.mod" },
	hooks = {
		{
			callback = function(dir)
				vim.notify("switched to dir: " .. dir)
			end,
		},
		{
			callback = function(dir)
				vim.notify("switched to dir: " .. dir)
			end, -- required, action when trigger the hook
			name = "cd hint", -- optional
			order = 1, -- optional, the exection order if there're multiple hooks to be trigger at one point
			pattern = "cd-project.nvim", -- trigger hook if contains pattern, optional
			trigger_point = "DISABLE", -- enum of trigger_points, optional, default to `AFTER_CD`
			match_rule = function(dir) -- optional, a function return bool. if have this fields, then pattern will be ignored
				return true
			end,
		},
	},
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

---@param dir string
---@return function[]
M.get_hooks = function(dir, point)
	local hooks = M.config.hooks
	local matching_hooks = {}

	for _, hook in ipairs(hooks) do
		local matches = false
		local trigger_point = hook.trigger_point or "AFTER_CD"

		-- Check if match_rule exists and returns true
		if hook.match_rule == nil and hook.pattern == nil then
			matches = true
		elseif hook.match_rule and hook.match_rule(dir) and trigger_point == point then
			matches = true
		-- If no match_rule, check if pattern exists in dir
		elseif hook.pattern and dir:find(hook.pattern) and trigger_point == point then
			matches = true
		end

		-- Add hook to matching_hooks if it matches
		if matches then
			table.insert(matching_hooks, hook)
		end
	end

	-- Sort hooks by order if order is defined
	table.sort(matching_hooks, function(a, b)
		return (a.order or 0) < (b.order or 0)
	end)

	-- Extract and return the callback functions from the matching hooks
	local callbacks = {}
	for _, hook in ipairs(matching_hooks) do
		table.insert(callbacks, hook.callback)
	end

	return callbacks
end

return M
