local buf = require("cereb.buffer")

local cereb_cli = require("cereb.cereb-cli")
local find_dir = require("cereb.find-dir")
local M = {}

local api = vim.api

local config = {
	cereb_cmd = "cereb",

	workspace = {
		root_patterns = { ".obsidian", ".git" },
		max_ancestor_depth = 30,
	},
}

local function find_workspace_root()
	return find_dir.find_dir_which_has_patterns(config.workspace.root_patterns, config.workspace.max_ancestor_depth)
end

local function cereb_page()
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)
	local page_contents = table.concat(lines, "\n")

	local last_line = vim.fn.line("$")
	cereb_cli.query_and_append_to_buffer_just_response(
		page_contents,
		config.cereb_cmd,
		last_line,
		find_workspace_root(),
		find_dir.current_dir()
	)
end

local function cereb_page_with_new_input()
	local lines = api.nvim_buf_get_lines(0, 0, -1, false)

	local user_input = vim.trim(vim.fn.input("your new query: "))
	if user_input == nil or user_input == "" then
		vim.notify("canceled")
		return
	end
	local page_contents = table.concat(lines, "\n")

	page_contents = page_contents .. "\n" .. "cereb-user\n" .. "---\n" .. user_input -- TODO(tacogips) dry

	local last_line = vim.fn.line("$")
	cereb_cli.query_and_append_to_buffer_with_latest_query(
		page_contents,
		config.cereb_cmd,
		last_line,
		find_workspace_root(),
		find_dir.current_dir()
	)
end

local function cereb_selected()
	local selected_text = buf.get_visual_selection()
	if selected_text == nil then
		vim.notify("no selected text")
	else
		local end_line = vim.fn.line("'>") + 1
		cereb_cli.query_and_append_to_buffer_just_response(selected_text.selection, config.cereb_cmd, end_line)
	end
end

local function cereb_selected_with_new_input()
	local selected_text = buf.get_visual_selection()
	if selected_text == nil then
		vim.notify("no selected text")
	else
		local user_input = vim.trim(vim.fn.input("your new query: "))
		if user_input == nil or user_input == "" then
			vim.notify("canceled")
			return
		end

		local query = selected_text.selection .. "\n" .. "cereb-user\n" .. "---\n" .. user_input -- TODO(tacogips) dry

		local end_line = vim.fn.line("'>")
		cereb_cli.query_and_append_to_buffer_with_latest_query(
			query,
			config.cereb_cmd,
			end_line,
			find_workspace_root(),
			find_dir.current_dir()
		)
	end
end

local function cereb_current_line()
	local current_line = vim.api.nvim_get_current_line()

	local current_line_number = vim.fn.line(".")
	cereb_cli.query_and_append_to_buffer_just_response(
		current_line,
		config.cereb_cmd,
		current_line_number,
		find_workspace_root(),
		find_dir.current_dir()
	)
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

	api.nvim_create_user_command(
		"CerebSelMdWithQuery",
		cereb_selected_with_new_input,
		{ nargs = 0, range = true, desc = "query selected as markdown with new input" }
	)
end

return M
