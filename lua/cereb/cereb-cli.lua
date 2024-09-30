local M = {}

M.query_and_append_to_buffer = function(input_string, cereb_cmd_path)
	input_string = vim.trim(input_string)
	if #input_string == 0 then
		vim.notify("No input string")
		return
	end

	local tmp_file = vim.fn.tempname()

	local cmd =
		string.format("echo '%s' | %s --no-history --no-latest-query > %s", input_string, cereb_cmd_path, tmp_file)
	os.execute(cmd)

	local file = io.open(tmp_file, "r")
	if file then
		local content = file:read("*all")
		file:close()

		local last_line = vim.fn.line("$")

		vim.api.nvim_buf_set_lines(0, last_line, -1, false, vim.split("\n" .. content, "\n"))

		-- 一時ファイルを削除
		os.remove(tmp_file)
	else
		print("Failed to read temporary file")
	end
end

return M
