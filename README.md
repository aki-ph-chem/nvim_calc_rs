# nvim\_calc\_rs

ref: https://medium.com/@srishanbhattarai/a-detailed-guide-to-writing-your-first-neovim-plugin-in-rust-a81604c606b1

## build

```bash
cargo build --release
```

## set by Lazy.nvim

```Lua
    --[[
        other plugins
    --]]
nvim_calc_rs = {
    dir = "path_to_rust_binary"
}

return {
    --[[
        other plugins
    --]]
    nvim_calc_rs
}
```

## Run

run by headless:

```bash
nvim --headless -c 'Add 2 3<CR>' -c 'qall!'
# => Sum 5
nvim --headless -c 'Multiply 2 3<CR>' -c 'qall!'
# => Product 6
```

run in Neovim

```txt
: Add 2 3
: Sum 5
```
```txt
: Multiply 2 3
: Product 6
```
