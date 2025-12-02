local util = require("webots.util")

--- Deprecated alias names.
---
---@class UserCommandAlias
---@field to string The new name of the user command
---@field version string The version that the alias will be removed in
local user_command_aliases = {
    ["WebotsRealtime"] = {
        to = "Webots",
        version = "never",
    },
}

--- Complete function providing worldfile relative paths (relative to Webots root)
---
--- Discards ArgLead and CursorPos.
---@param _ string ArgLead
---@param line string The entire command line
---@return table
local webots_complete = function(_, line)
    local l = vim.split(line, "%s+")
    return vim.tbl_filter(
        function(val) return vim.startswith(val, l[#l]) end,
        vim.tbl_map(
            function(item) return util.project_relative_path(item):sub(#"worlds/" + 1) end,
            util.find_worldfiles()
        )
    )
end

--- Makes a new command (function) selecting a worldfile and executing the given
--- function on the it
---
---@param f fun(worldfile: string) Function that takes the full path to a worldfile
---@return fun(opts: table) command New command
local webots_worldfile_command = function(f)
    local worldfile_full_path = function(relative_worldfile_path)
        return util.project_full_path(string.format("worlds/%s", relative_worldfile_path))
    end
    local worldfile_relative_path = function(full_worldfile_path)
        return util.project_relative_path(full_worldfile_path):sub(#"worlds/" + 1)
    end

    return function(opts)
        local fargs = opts.fargs
        if #fargs == 1 then
            f(worldfile_full_path(fargs[1]))
            return
        end
        if #fargs > 1 then
            error("Too many arguments.")
        end
        local worldfiles = util.find_worldfiles()
        if #worldfiles == 1 then
            f(worldfile_full_path(worldfiles[1]))
            return
        end
        if #worldfiles < 1 then
            error("There are no existing worldfiles")
        end
        vim.ui.select(worldfiles, {
            prompt = "Select a worldfile to run",
            format_item = function(item) return worldfile_relative_path(item) end,
        }, function(choice)
            if choice == nil then
                return
            end
            f(worldfile_full_path(choice))
        end)
    end
end

--- User commands
---
--- See :help nvim_create_user_command()
---@class UserCommand
---@field command fun(opts)|string Replacement command to execute
---@field opts table|nil Optional command-attributes
local user_commands = {
    ["Webots"] = {
        command = webots_worldfile_command(util.webots_realtime),
        opts = { nargs = "*", complete = webots_complete },
    },
    ["WebotsFast"] = {
        command = webots_worldfile_command(util.webots_fast),
        opts = { nargs = "*", complete = webots_complete },
    },
}

for k, v in pairs(user_commands) do
    vim.api.nvim_create_user_command(k, v.command, v.opts)
end

for k, v in pairs(user_command_aliases) do
    vim.api.nvim_create_user_command(k, function(opts)
        vim.cmd(string.format("%s %s", v.to, opts.args))
        vim.notify(
            string.format(
                [[prefer user command "%s" instead of "%s", which will be removed in version %s]],
                v.to,
                k,
                v.version
            ),
            vim.log.levels.WARN
        )
    end, user_commands[v.to].opts)
end
