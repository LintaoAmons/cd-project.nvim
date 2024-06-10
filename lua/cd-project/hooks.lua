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
---@return function[]
local get_hooks = function(hooks, dir, point)
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

return {
  get_hooks = get_hooks,
}
