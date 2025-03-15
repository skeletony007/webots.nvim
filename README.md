### Webots.nvim

Configurations to make [Webots] work with Neovim.

[Webots]: https://github.com/cyberbotics/webots

### Instalation

Using [lazy.nvim]

```lua
return {
    "skeletony007/webots.nvim",

    setup = true
}
```

[lazy.nvim]: https://github.com/folke/lazy.nvim

### Extras

#### Jdtls

Sets up [Eclipse JDT Language Server] to use the Webots libraries.

[Eclipse JDT Language Server]: https://github.com/eclipse-jdtls/eclipse.jdt.ls

#### Open JDK

Sets up openjdk with Neovim `:make` command.
