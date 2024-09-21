local calculatorJobLuaId = 0

local bin = "/home/aki/nvim_calc_rs/target/release/nvim_calc_rs"

local connect = function()
	local id = initRpc()

	if 0 == id then
		print("calculator: cannot start rpc process")
	elseif -1 == id then
		print("calculator: cannot start rpc process")
	else
		print("initRpc(): Ok")
		print("id = " .. id)
		calculatorJobLuaId = id
	end
end

--- initialize RPC
initRpc = function()
	if calculatorJobLuaId == 0 then
		jobid = vim.fn.jobstart(bin, { rpc = true })
		return jobid
	else
		return calculatorJobLuaId
	end
end

vim.api.nvim_create_user_command("AddL", function(ops)
	local args = ops.fargs
	if #args < 2 then
		return
	end
	local p = tonumber(args[1])
	local q = tonumber(args[2])

	print("calculatorJobLuaId(in AddL) = " .. calculatorJobLuaId)

	vim.rpcnotify(calculatorJobLuaId, "add", p, q)
end, { nargs = "*" })

vim.api.nvim_create_user_command("MulL", function(ops)
	local args = ops.fargs
	if #args < 2 then
		return
	end
	local p = tonumber(args[1])
	local q = tonumber(args[2])

	vim.rpcnotify(calculatorJobLuaId, "multiply", p, q)
end, { nargs = "*" })

connect()
