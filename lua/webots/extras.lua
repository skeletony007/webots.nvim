local configs = {}

local util = require("webots.util")
local api = vim.api
local tbl_deep_extend, tbl_contains = vim.tbl_deep_extend, vim.tbl_contains

--- @class webots.Config
--- @field name? string
--- @field filetypes? string[]
--- @field callback? fun(opts)

---@param t table
---@param config_name string
---@param config_def table Config definition read from `webots.configs.<name>`.
function configs.__newindex(t, config_name, config_def)
    local M = {}

    local default_config = tbl_deep_extend("keep", config_def.default_config, util.default_config)

    -- Force this part.
    default_config.name = config_name

    --- @param user_config webots.Config
    function M.setup(user_config)
        user_config = user_config or {}

        local webots_group = api.nvim_create_augroup("webots", { clear = false })

        local config = tbl_deep_extend("keep", user_config, default_config)

        local event_conf = config.filetypes and { event = "FileType", pattern = config.filetypes }
            or {
                event = "BufReadPost",
            }
        event_conf.callback = function(opts)
            local webots_root = util.webots_root(opts.buf)
            if webots_root ~= nil then
                config.callback({ buf = opts.buf })
            end
            util.current_root = webots_root
        end
        api.nvim_create_autocmd(event_conf.event, {
            pattern = event_conf.pattern or "*",
            callback = event_conf.callback,
            group = webots_group,
            desc = string.format("Checks whether extra %s should start.", config.name),
        })

        -- forcefully execute callback on the current buffer if needed
        local buf = api.nvim_get_current_buf()
        if
            event_conf.pattern
            and not tbl_contains(event_conf.pattern, api.nvim_get_option_value("filetype", { buf = buf }))
        then
            return
        end
        event_conf.callback({ buf = buf })
    end

    rawset(t, config_name, M)
end

return setmetatable({}, configs)
