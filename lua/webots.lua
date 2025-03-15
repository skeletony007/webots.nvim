local job = require("plenary.job")

local api = vim.api
local extras = require("webots.extras")

M.webots_realtime = function()
    local find_head = job:new({
        "webots",
        "--mode=realtime",
        "--stdout",
        "--stderr",
        cwd = vim.loop.cwd(),
    })
    local stdout, code = find_head:sync()
    if code ~= 0 then
        error("Error running webots in realtime mode")
    end

    return stdout
end

-- api.nvim_create_user_command('Webots', ...

M = {}

--- Deprecated extra names.
---
---@class Alias
---@field to string The new name of the extra
---@field version string The version that the alias will be removed in
---@field inconfig? boolean should display in healthcheck (`:checkhealth webots`)
local aliases = {
    ["example"] = {
        to = "new_example",
        version = "0.2.1",
    },
}

---@return Alias
---@param name string|nil get this alias, or nil to get all aliases that were used in the current session.
M.extras_alias = function(name)
    if name then
        return aliases[name]
    end
    local used_aliases = {}
    for sname, alias in pairs(aliases) do
        if alias.inconfig then
            used_aliases[sname] = alias
        end
    end
    return used_aliases
end

local mt = {}
function mt:__index(k)
    if extras[k] == nil then
        local alias = M.extras_alias(k)
        if alias then
            vim.deprecate(k, alias.to, alias.version, "webots.nvim", false)
            alias.inconfig = true
            k = alias.to
        end

        local success, extra = pcall(require, "webots.extras." .. k)
        if success then
            extras[k] = extra
        else
            vim.notify(string.format('[webots] extra "%s" not found.', k), vim.log.levels.WARN)
            -- Return a dummy function for compatibility with user configs
            return { setup = function() end }
        end
    end
    return extras[k]
end

return setmetatable(M, mt)
