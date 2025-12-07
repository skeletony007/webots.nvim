### Webots.nvim

Configurations to make [Webots] work with Neovim.

[Webots]: https://github.com/cyberbotics/webots

### Instalation

Using [lazy.nvim]

```lua
return {
    "skeletony007/webots.nvim",

    cmd = {
        "Webots",
        "WebotsRealtime",
        "WebotsFast",
        
        -- currently only implemented for Open JDK
        "WebotsExternRobotController",
    },

    ft = {
        "wbt",
        "wbproj",
    },
}
```

[lazy.nvim]: https://github.com/folke/lazy.nvim

### Extras

```
require("webots").<extra>.setup(<config>)
```

#### Jdtls

Sets up [Eclipse JDT Language Server] to use the Webots libraries using the
`"workspace/didChangeConfiguration"` method.

```lua
require("webots").jdtls.setup()
```

[Eclipse JDT Language Server]: https://github.com/eclipse-jdtls/eclipse.jdt.ls

#### Open JDK

Sets up openjdk with Neovim `:make` command and adds
`:WebotsExternRobotController` user command to [run extern robot controllers].

```lua
require("webots").openjdk.setup()
```

[run extern robot controllers]:
https://cyberbotics.com/doc/guide/running-extern-robot-controllers
