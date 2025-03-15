local util = require("webots.util")

return {
    default_config = {
        callback = function()
            -- setup jdtls
            vim.lsp.config("jdtls", {
                settings = {
                    java = {
                        project = {
                            referencedLibraries = util.libraries,
                        },
                    },
                },
            })

            -- restart jdtls
            vim.lsp.enable("jdtls", false)
            vim.lsp.enable("jdtls", true)
        end,
        filetypes = {
            "java",
        },
    },
}
