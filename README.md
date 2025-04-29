# TestNav.vim

Navigate in Neovim b/w source <-> test with `:TestNav` command.

## Install with Lazy.nvim

In `~/.config/nvim/lua/plugins/testnav.vim`:

```lua
return {
    "eighty4/testnav.vim",
    cmd = {
        "TestNav",
    },
    keys = {
        { "<leader>tn", "<cmd>TestNav<cr>", desc = "Nav b/w source <-> test" },
    },
}

```

Personal config [eighty4/nvim](https://github.com/eighty4/nvim/blob/main/lua/adam/lazy.lua) example of Lazy.nvim setup.

## TODO

- resolve Rust `#[cfg(test)]` submodules and adjacent `#[cfg(test)] mod XXX_test` modules
- resolve Flutter test directory

