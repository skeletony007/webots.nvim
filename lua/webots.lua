local extras = require("webots.extras")

require("webots.user_commands")

M = {}

--- Deprecated extra names.
---
---@class ExtrasAlias
---@field to string The new name of the extra
---@field version string The version that the alias will be removed in
---@field inconfig? boolean should display in healthcheck (`:checkhealth webots`)
local extras_aliases = {
    ["example"] = {
        to = "new_example",
        version = "0.2.1",
    },
}

local mt = {}
function mt:__index(k)
    if extras[k] == nil then
        local alias = extras_aliases[k]
        if alias then
            vim.deprecate(k, alias.to, alias.version, "webots.nvim", false)
            alias.inconfig = true
            k = alias.to
        end

        local success, extra = pcall(require, "webots.extras." .. k)
        if success then
            extras[k] = extra
        else
            vim.notify(string.format([[[webots] extra "%s" not found.]], k), vim.log.levels.WARN)
            -- Return a dummy function for compatibility with user configs
            return { setup = function() end }
        end
    end
    return extras[k]
end

return setmetatable(M, mt)
