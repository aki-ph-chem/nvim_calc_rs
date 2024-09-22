# nvim\_calc\_rs

ref: https://medium.com/@srishanbhattarai/a-detailed-guide-to-writing-your-first-neovim-plugin-in-rust-a81604c606b1

## features

- Add : add two numbers
- AddL : add two numbers
- Multiply : multiply two numbers
- MulL : multiply two numbers
- MulAll: multiply all numbers
- SumAll: add all numbers
- Average: calculate average of all numbers

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

## install

### build

```bash
cargo build --release
```

### set by Lazy.nvim

in lua/plugins.lua
```Lua
    --[[
        other plugins
    --]]
nvim_calc_rs = {
    dir = "path_to_this_directory"
}

return {
    --[[
        other plugins
    --]]
    nvim_calc_rs
}
```
