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

local mergeLines = function(t1, t2)
	for _, v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

local _query_and_append_to_buffer = function(input_string, cereb_cmd_path, args, output_row)
	input_string = vim.trim(input_string)
	if #input_string == 0 then
		vim.notify("No input string")
		return
	end

	local callback = function(result)
		if not result then
			vim.notify("cereb: failed to get result")
		else
			local result_lines = vim.split("\n" .. result .. "\n", "\n")

			local existing_lines = vim.api.nvim_buf_get_lines(0, output_row, -1, false)
			local merged_lines = mergeLines(result_lines, existing_lines)

			vim.api.nvim_buf_set_lines(0, output_row, -1, false, merged_lines)
		end
	end

	run_cereb_command(input_string, args, cereb_cmd_path, callback)
end

local function dir_args(workspace_root_dir, current_buffer_dir)
	local args = {}
	if workspace_root_dir ~= nil then
		table.insert(args, "--work-root-dir=" .. workspace_root_dir)
	end

	if current_buffer_dir ~= nil then
		table.insert(args, "--work-current-dir=" .. current_buffer_dir)
	end

	return args
end

M.query_and_append_to_buffer_just_response = function(
	input_string,
	cereb_cmd_path,
	output_row_num,
	workspace_root_dir,
	current_buffer_dir
)
	local args = { "--no-history", "--no-latest-query" }
	args = vim.tbl_extend("force", args, dir_args(workspace_root_dir, current_buffer_dir))
	_query_and_append_to_buffer(input_string, cereb_cmd_path, args, output_row_num)
end

M.query_and_append_to_buffer_with_latest_query = function(
	input_string,
	cereb_cmd_path,
	output_row,
	workspace_root_dir,
	current_buffer_dir
)
	local args = { "--no-history" }
	args = vim.tbl_extend("force", args, dir_args(workspace_root_dir, current_buffer_dir))
	_query_and_append_to_buffer(input_string, cereb_cmd_path, args, output_row)
end

return M
