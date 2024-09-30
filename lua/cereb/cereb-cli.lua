local Job = require("plenary.job")

local M = {}
local function run_cereb_command(input_text, cmd_path, callback, timeout)
	local job = Job:new({
		command = cmd_path,
		args = { "--no-history", "--no-latest-query" },
		writer = input_text,
		timeout = timeout or 600000,
		on_stderr = function(_, data)
			vim.notify("cereb error: " .. data)
		end,
	})

	local result, _ = job:sync(timeout or 600000)
	if result then
		callback(table.concat(result, "\n"))
	end
end

M.query_and_append_to_buffer = function(input_string, cereb_cmd_path)
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

	run_cereb_command(input_string, cereb_cmd_path, callback)
end

return M
