local util = require("webots.util")

return {
    default_config = {
        callback = function(opts)
            vim.bo[opts.buf].makeprg =
                string.format([[javac -Xlint -classpath "%s" "%s"]], table.concat(util.java_libraries, ":"), "%")

            -- Set WebotsExternRobotController user command
            --
            -- Example:
            --
            -- ```
            -- java -XstartOnFirstThread \
            --      -classpath $WEBOTS_HOME_PATH/lib/controller/java/Controller.jar:$WEBOTS_ROOT/controllers/DriveController/ \
            --      -Djava.library.path=$WEBOTS_HOME_PATH/lib/controller/java \
            --      DriveController
            -- ```
            vim.api.nvim_buf_create_user_command(opts.buf, "WebotsExternRobotController", function(o)
                local fargs = o.fargs
                if #fargs ~= 1 then
                    error("Wrong number of arguments (expected 1)")
                end
                local relative_path = fargs[1]
                local full_path = util.project_full_path(string.format("controllers/%s", relative_path))
                vim.cmd(
                    string.format(
                        [[!java -XstartOnFirstThread -classpath "%s" -Djava.library.path="%s/lib/controller/java" "%s"]],
                        string.format("%s:%s", table.concat(util.java_libraries, ":"), vim.fs.dirname(full_path)),
                        util.webots_home_path,
                        vim.fs.basename(full_path)
                    )
                )
            end, {
                nargs = "*",
                complete = function(_, line)
                    local class_files = vim.fs.find(function(name) return name:match(".*%.class$") end, {
                        limit = math.huge,
                        type = "file",
                        path = string.format("%s/controllers", util.current_root),
                    })
                    print("find files" .. vim.inspect(class_files))
                    local l = vim.split(line, "%s+")
                    return vim.tbl_filter(
                        function(val) return vim.startswith(val, l[#l]) end,
                        vim.tbl_map(
                            function(item)
                                return util.project_relative_path(item):sub(#"controllers/" + 1):match("^(.*).class$")
                            end,
                            class_files
                        )
                    )
                end,
            })
        end,
        filetypes = {
            "java",
        },
    },
}
