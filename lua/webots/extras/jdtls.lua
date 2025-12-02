local util = require("webots.util")

return {
    default_config = {
        callback = function()
            vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", {
                settings = {
                    java = {
                        project = {
                            referencedLibraries = util.java_libraries,
                        },
                    },
                },
            })
        end,
        filetypes = {
            "java",
        },
    },
}
