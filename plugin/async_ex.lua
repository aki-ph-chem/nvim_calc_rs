local function run_ping_command_async(config)
	if config.new_window then
		vim.api.nvim_command("vnew")
	end

	-- Execute the `ping` command as an external process
	local job_id = vim.fn.jobstart("ping -c 3 google.com", {
		on_stdout = function(job_id, data, event)
			if data then
				-- Add the ping output to the current buffer in real time
				vim.api.nvim_buf_set_lines(0, -1, -1, false, data)
			end
		end,
		on_stderr = function(job_id, data, event)
			-- Display error messages (if any)
			print("Error:", table.concat(data, "\n"))
		end,
		on_exit = function(job_id, exit_code, event)
			-- Display the exit code when the process finishes
			print("Ping command exited with code", exit_code)
		end,
	})

	vim.cmd("setlocal buftype=nofile")
	print("Started job with id", job_id)
end

local config_ping = {
	new_window = true,
}

local function run_ping_command_async_window()
	-- window size and position
	local width = 50
	local height = 15
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- buffer for floating window
	local buf = vim.api.nvim_create_buf(false, true)

	-- options for floating window
	local opts = {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		border = "rounded",
	}

	-- generate floating window
	vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "ping command start" })

	-- Execute the `ping` command as an external process
	local job_id = vim.fn.jobstart("ping -c 10 google.com", {
		on_stdout = function(job_id, data, event)
			if data then
				-- Get the current number of lines in the buffer
				local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

				-- Combine current lines with new data
				local new_lines = vim.list_extend(current_lines, data)

				-- Set the updated lines back to the buffer
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
			end
		end,
		on_stderr = function(job_id, data, event)
			-- Display error messages (if any)
			print("Error:", table.concat(data, "\n"))
		end,
		on_exit = function(job_id, exit_code, event)
			-- Display the exit code when the process finishes
			print("Ping command exited with code", exit_code)
		end,
	})
	vim.cmd("setlocal buftype=nofile")

	print("Started job with id", job_id)
end

vim.api.nvim_create_user_command("Ping", function()
	run_ping_command_async(config_ping)
end, { nargs = 0 })

vim.api.nvim_create_user_command("PingWin", function()
	run_ping_command_async_window()
end, { nargs = 0 })
