local util = require("webots.util")

return {
    default_config = {
        callback = function()
            vim.bo.makeprg =
                string.format([[javac -Xlint -classpath "%s" "%s"]], table.concat(util.libraries, ":"), "%")
        end,
        filetypes = {
            "java",
        },
    },
}
