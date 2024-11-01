# nvim-gmod-luadev
Commands for [LuaDev](https://github.com/Metastruct/luadev)'s SocketDev; send code from your editor to the game

## Installation
Add `wrldspawn/nvim-gmod-luadev` to your favorite plugin manager and call `require("nvim-gmod-luadev").setup()`.
A table can be passed to setup, the only option currently is `port` (default `27099`)

### lazy.nvim
```lua
{
    "wrldspawn/nvim-gmod-luadev",
    -- optional, shouldn't need to change the port
    opts = {
        port = 27099, -- default
    },
    -- lazyload on filetype
    ft = "lua",
    -- or on command
    cmd = {"LuadevSelf", "LuadevSv", "LuadevCl", "LuadevSh", "LuadevClient"},
    -- setup keybinds (optional)
    -- NOTE: if you're using a terminal and want to use Ctrl-1 through 5 you will need to bind them to \e[49;5u through
    --       \e[53;5u respectively in your terminal's config, if possible
    keys = {
        {"<C-1>", "<Cmd>LuadevSelf<CR>",   desc = "LuaDev: Run on self",            mode = "n"},
        {"<C-2>", "<Cmd>LuadevSv<CR>",     desc = "LuaDev: Run on server",          mode = "n"},
        {"<C-3>", "<Cmd>LuadevCl<CR>",     desc = "LuaDev: Run on clients",         mode = "n"},
        {"<C-4>", "<Cmd>LuadevSh<CR>",     desc = "LuaDev: Run on shared",          mode = "n"},
        {"<C-5>", "<Cmd>LuadevClient<CR>", desc = "LuaDev: Run on specific player", mode = "n"},
    },
}
```
