local Job = require("plenary.job")

local M = {}
local function run_cereb_command(input_text, args, cmd_path, callback, timeout)
	local error_msg = ""
	local job = Job:new({
		command = cmd_path,
		args = args,
		writer = input_text,
		timeout = timeout or 600000,
		on_stderr = function(_, data)
			error_msg = data
		end,
	})

	local result, _ = job:sync(timeout or 600000)

	if error_msg ~= "" then
		vim.notify("cereb error: " .. error_msg)
	end
	if result then
		callback(table.concat(result, "\n"))
	end
end

local _query_and_append_to_buffer = function(input_string, cereb_cmd_path, args)
	input_string = vim.trim(input_string)
	if #input_string == 0 then
		vim.notify("No input string")
		return
	end

	local callback = function(result)
		if not result then
			vim.notify("cereb: failed to get result")
		else
			local last_line = vim.fn.line("$")
			vim.api.nvim_buf_set_lines(0, last_line, -1, false, vim.split("\n" .. result, "\n"))
		end
	end

	run_cereb_command(input_string, args, cereb_cmd_path, callback)
end

M.query_and_append_to_buffer_just_response = function(input_string, cereb_cmd_path)
	_query_and_append_to_buffer(input_string, cereb_cmd_path, { "--no-history", "--no-latest-query" })
end

M.query_and_append_to_buffer_with_latest_query = function(input_string, cereb_cmd_path)
	_query_and_append_to_buffer(input_string, cereb_cmd_path, { "--no-history" })
end

return M
