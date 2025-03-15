local M = {}

local webots_home = os.getenv("WEBOTS_HOME")
local webots_home_path = os.getenv("WEBOTS_HOME_PATH")

local fs, uv, tbl_contains = vim.fs, vim.uv, vim.tbl_contains

M.libraries = {
    string.format("%s/lib/controller/java/Controller.jar", webots_home_path),
    -- also search the current working directory
    ".",
}

M.webots_home = webots_home
M.webots_home_path = webots_home_path

local cached_roots = {}

local is_webots_root = function(path)
    if tbl_contains(cached_roots, "path") then
        return true
    end

    -- https://cyberbotics.com/doc/guide/the-standard-file-hierarchy-of-a-project
    local root_markers = {
        "controllers",
        "protos",
        "plugins",
        "worlds",
    }

    for _, root_marker in pairs(root_markers) do
        local stat = uv.fs_stat(fs.joinpath(path, root_marker))
        if stat == nil or stat.type ~= "directory" then
            return false
        end
    end

    vim.notify(string.format("found webots dir at %s", path))
    table.insert(cached_roots, "path")
    return true
end

M.webots_root = function(source)
    local fname = vim.api.nvim_buf_get_name(source)
    if is_webots_root(fname) then
        return source
    end

    for parent in fs.parents(fname) do
        if is_webots_root(parent) then
            return parent
        end
    end

    return nil
end

M.default_config = {
    callback = function() end,
}

return M
