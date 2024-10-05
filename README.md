# nvim\_calc\_rs

ref: https://medium.com/@srishanbhattarai/a-detailed-guide-to-writing-your-first-neovim-plugin-in-rust-a81604c606b1

## features

- AddL : add two numbers
- MulL : multiply two numbers
- MulAll: multiply all numbers
- SumAll: add all numbers
- Average: calculate average of all numbers

## Run

run by headless:

```bash
nvim --headless -c 'AddL 2 3<CR>' -c 'qall!'
# => Sum 5
nvim --headless -c 'MulL 2 3<CR>' -c 'qall!'
# => Product 6
```

run in Neovim

```txt
: AddL 2 3
: SumL 5
```

## install

Whichever method you use, you will need to prepare an environment in which you can build a Rust project with `Cargo`.

### method 1: Perform the build of this project by yourself

First, clone this repository and run the build

```bash
git clone https://github.com/aki-ph-chem/nvim_calc_rs.git
cd nvim_calc_rs
cargo build --release
```

Then, configure your plugin manager, such as `Lazy.nvim`, as follows

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

### method 2: Leave it to the Plugin Manager to automatically perform Rust builds.

configure your plugin manager, such as `Lazy.nvim`, as follows

```Lua
nvim_calc_rs = {
	"aki-ph-chem/nvim_calc_rs"
}

return {
    --[[
        other plugins
    --]]
    nvim_calc_rs
}
```

After that, when Neovim is started, the first time it is started,
`Cargo` will automatically run the build and complete the setup.

## ToDo

- [x] To be able to automatically run the Rust build on first startup.
- [ ] Support for hot reloading
- [ ] Support for automatic build of Rust at appdate by Lazy.nvim
