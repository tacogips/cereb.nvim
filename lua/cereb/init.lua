local buf = require("cereb.buffer")

local cereb_cli = require("cereb.cereb-cli")
local M = {}

local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

local config = {
	cereb_bin_path = "cereb",
}

local function cereb_page()
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)
	local page_contents = table.concat(lines, "\n")

	cereb_cli.query_and_append_to_buffer_just_response(page_contents, config.cereb_bin_path)
end

local function cereb_page_with_new_input()
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)

	local user_input = vim.fn.input("your new query: ")
	if user_input == nil or user_input == "" then
		vim.notify("canceled")
		return
	end
	local page_contents = table.concat(lines, "\n")
	page_contents = page_contents .. "\n" .. "cereb-user\n" .. "---\n" .. user_input

	cereb_cli.query_and_append_to_buffer_with_latest_query(page_contents, config.cereb_bin_path)
end

local function cereb_selected()
	local selected_text = buf.get_visual_selection()
	if selected_text == nil then
		vim.notify("no selected text")
	else
		cereb_cli.query_and_append_to_buffer_just_response(selected_text.selection, config.cereb_bin_path)
	end
end

local function cereb_current_line()
	local current_line = vim.api.nvim_get_current_line()
	cereb_cli.query_and_append_to_buffer_just_response(current_line, config.cereb_bin_path)
end

function M.setup(user_options)
	config = vim.tbl_deep_extend("force", config, user_options)

	api.nvim_create_user_command("CerebPageMd", cereb_page, { nargs = 0, desc = "query current page as markdown" })
	api.nvim_create_user_command(
		"CerebPageMdWithQuery",
		cereb_page_with_new_input,
		{ nargs = 0, desc = "query current page as markdown with new input" }
	)

	api.nvim_create_user_command(
		"CerebCurrentLineMd",
		cereb_current_line,
		{ nargs = 0, desc = "query current page as markdown" }
	)
	api.nvim_create_user_command(
		"CerebSelMd",
		cereb_selected,
		{ nargs = 0, range = true, desc = "query selected as markdown" }
	)
end

return M
