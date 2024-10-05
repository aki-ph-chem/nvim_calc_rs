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

vim.api.nvim_create_user_command("Ping", function()
	run_ping_command_async(config_ping)
end, { nargs = 0 })
