local M = {}

---@class CdProject.Hook
---@field callback fun(param: string)
---@field name? string
---@field order? number
---@field trigger_point? string
---@field pattern? string
---@field match_rule? fun(dir: string): boolean
---
---@param hooks CdProject.Hook[]
---@param dir string
---@param point string
---@return CdProject.Hook[]
M.get_hooks = function(hooks, dir, point)
  local matching_hooks = {}
  for _, hook in ipairs(hooks) do
    local matches = false
    local trigger_point = hook.trigger_point or "AFTER_CD"

    -- Check if the hook's trigger_point matches the given point
    if trigger_point ~= point then
      matches = false
    -- Check if match_rule exists and returns true
    elseif hook.match_rule and hook.match_rule(dir) then
      matches = true
    -- If no match_rule, check if pattern exists in dir
    elseif hook.pattern and dir:find(hook.pattern) then
      matches = true
    -- If neither match_rule nor pattern is specified, consider it a match
    elseif hook.match_rule == nil and hook.pattern == nil then
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

  return matching_hooks
end

return M
