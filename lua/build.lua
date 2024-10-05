require("utl")

get_project_root_dir = function()
	-- get path to project root
	local plugin = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
	local plugin_root = plugin:gsub("/lua/?$", "")
	return plugin_root
end

local is_diff_in_src = function()
	local diff = vim.fn.systemlist("git diff --name-only", get_project_root_dir())

	for _, file_name in ipairs(diff) do
		if file_name:match("Cargo.toml") or file_name:match(".*rs$") then
			return true
		end
	end
	return false
end

build_rust = function(is_debug, state)
	local project_root_dir = get_project_root_dir()
	local path_to_bin = project_root_dir .. "/target/release/nvim_calc_rs"

	if is_debug then
		print("projet_root_dir: " .. project_root_dir)
		print("path_to_bin: " .. path_to_bin)
	end

	if not vim.loop.fs_stat(path_to_bin) then
		print("build rust binary ...")

		local build_cmd = "cargo build --release --manifest-path=" .. project_root_dir .. "/Cargo.toml"
		if is_debug then
			print("build_cmd: " .. build_cmd)
		end

		local result_build = vim.fn.systemlist(build_cmd)
		for _, line in ipairs(result_build) do
			print(line)
		end

		print("build: Ok")
	end

	connect_to_bin(state)
end
