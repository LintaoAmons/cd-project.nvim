local M = {}

---@class CdProject.Hook
---@field callback fun(param: string)
---@field name? string
---@field order? number
---@field cd_cmd? "cd" | "tabe | tcd" | "lcd"
---@field trigger_point? string
---@field pattern? string
---@field match_rule? fun(dir: string): boolean
---
---@param hooks CdProject.Hook[]
---@param dir string
---@param point string
---@param cd_cmd? "cd" | "tabe | tcd" | "lcd"
---@return CdProject.Hook[]
M.get_hooks = function(hooks, dir, point, cd_cmd)
  local matching_hooks = {}
  for _, hook in ipairs(hooks) do
    local trigger_point = hook.trigger_point or "AFTER_CD"

    if trigger_point ~= point then
      goto continue
    end

    if hook.cd_cmd and hook.cd_cmd ~= cd_cmd then
      goto continue
    end

    -- match_rule wins over pattern; a hook with neither always matches
    local matches = false
    if hook.match_rule and hook.match_rule(dir) then
      matches = true
    elseif hook.pattern and dir:find(hook.pattern) then
      matches = true
    elseif hook.match_rule == nil and hook.pattern == nil then
      matches = true
    end

    if matches then
      table.insert(matching_hooks, hook)
    end
    ::continue::
  end

  table.sort(matching_hooks, function(a, b)
    return (a.order or 0) < (b.order or 0)
  end)

  return matching_hooks
end

return M
