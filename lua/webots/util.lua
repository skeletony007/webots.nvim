local M = {}

M.webots_home = os.getenv("WEBOTS_HOME")
M.webots_home_path = os.getenv("WEBOTS_HOME_PATH")

M.java_libraries = {
    string.format("%s/lib/controller/java/Controller.jar", M.webots_home_path),
    -- also search the current working directory
    ".",
}

M.current_root = nil

local cached_roots = {}

local is_webots_root = function(path)
    if vim.tbl_contains(cached_roots, path) then
        return true
    end

    -- https://cyberbotics.com/doc/guide/the-standard-file-hierarchy-of-a-project
    if M.find_worldfiles(path) == nil then
        return false
    end

    table.insert(cached_roots, path)
    return true
end

M.webots_root = function(source)
    local fname = vim.api.nvim_buf_get_name(source)
    if is_webots_root(fname) then
        return fname
    end

    for parent in vim.fs.parents(fname) do
        if is_webots_root(parent) then
            return parent
        end
    end

    return nil
end

M.find_worldfiles = function(webots_root)
    return vim.fs.find(function(name) return name:match(".*%.wbt$") end, {
        limit = math.huge,
        type = "file",
        path = string.format("%s/worlds", webots_root),
    })
end

--- Get the relative path to a project file under webots root from its full path
--- to a project file
---@param full_path string full path
---@return string relative_path relative path
M.project_relative_path = function(full_path) return full_path:sub(#string.format("%s/", M.current_root) + 1) end

--- Get the full path to a project file from its relative path to a project file
--- under webots root
---@param relative_path string relative path
---@return string full_path full path
M.project_full_path = function(relative_path) return string.format("%s/%s", M.current_root, relative_path) end

M.hsplit_command = function(cmd)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false

    local win = vim.api.nvim_open_win(buf, true, { split = "below", height = 15 })
    vim.wo[win].previewwindow = true

    --- Append output to buffer
    ---@param _ string error
    ---@param data string|nil output
    local function append(_, data)
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            if type(data) ~= "string" then
                return
            end
            local lines = vim.split(data, "\n", { plain = true, trimempty = false })
            if lines[#lines] == "" then
                table.remove(lines)
            end
            vim.bo[buf].modifiable = true
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
            vim.bo[buf].modifiable = false
            vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
        end)
    end

    append("", string.format(table.concat(cmd, " ")))

    local obj = vim.system(cmd, {
        cwd = vim.loop.cwd(),
        text = true,
        stdout = append,
        stderr = append,
    }, function(obj) append("", string.format("-- Exit status %d --", obj.code)) end)

    vim.keymap.set("n", "<C-c>", function()
        if obj:is_closing() then
            obj:kill("sigint")
            append("", "\n-- Interrupted --\n")
        end
    end, { buffer = buf, silent = true })
end

--- Start a Webots instance in realtime mode
---@param worldfile string
M.webots_realtime = function(worldfile)
    M.hsplit_command({
        "webots",
        "--mode=realtime",
        "--stdout",
        "--stderr",
        worldfile,
    })
end

--- Start a Webots instance in fast mode
---@param worldfile string world file name
M.webots_fast = function(worldfile)
    M.hsplit_command({
        "webots",
        "--mode=fast",
        "--stdout",
        "--stderr",
        worldfile,
    })
end

M.default_config = {
    callback = function() end,
}

return M
