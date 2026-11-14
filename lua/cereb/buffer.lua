local util = {}

-- thanks to https://github.com/epwalsh/obsidian.nvim

--- Get the current visual selection of text and exit visual mode.
---
---@param opts { strict: boolean|? }|?
---
---@return { lines: string[], selection: string, csrow: integer, cscol: integer, cerow: integer, cecol: integer }|?
util.get_visual_selection = function(opts)
	opts = opts or {}
	-- Adapted from fzf-lua:
	-- https://github.com/ibhagwan/fzf-lua/blob/6ee73fdf2a79bbd74ec56d980262e29993b46f2b/lua/fzf-lua/utils.lua#L434-L466
	-- this will exit visual mode
	-- use 'gv' to reselect the text
	local _, csrow, cscol, cerow, cecol
	local mode = vim.fn.mode()
	if opts.strict and not vim.endswith(string.lower(mode), "v") then
		return
	end

	if mode == "v" or mode == "V" or mode == "" then
		-- if we are in visual mode use the live position
		_, csrow, cscol, _ = unpack(vim.fn.getpos("."))
		_, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
		if mode == "V" then
			-- visual line doesn't provide columns
			cscol, cecol = 0, 999
		end
		-- exit visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	else
		-- otherwise, use the last known visual position
		_, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
		_, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
	end

	-- Swap vars if needed
	if cerow < csrow then
		csrow, cerow = cerow, csrow
		cscol, cecol = cecol, cscol
	elseif cerow == csrow and cecol < cscol then
		cscol, cecol = cecol, cscol
	end

	local lines = vim.fn.getline(csrow, cerow)
	assert(type(lines) == "table")
	if vim.tbl_isempty(lines) then
		return
	end

	-- When the whole line is selected via visual line mode ("V"), cscol / cecol will be equal to "v:maxcol"
	-- for some odd reason. So change that to what they should be here. See ':h getpos' for more info.
	local maxcol = vim.api.nvim_get_vvar("maxcol")
	if cscol == maxcol then
		cscol = string.len(lines[1])
	end
	if cecol == maxcol then
		cecol = string.len(lines[#lines])
	end

	---@type string
	local selection
	local n = #lines
	if n <= 0 then
		selection = ""
	elseif n == 1 then
		selection = string.sub(lines[1], cscol, cecol)
	elseif n == 2 then
		selection = string.sub(lines[1], cscol) .. "\n" .. string.sub(lines[n], 1, cecol)
	else
		selection = string.sub(lines[1], cscol)
			.. "\n"
			.. table.concat(lines, "\n", 2, n - 1)
			.. "\n"
			.. string.sub(lines[n], 1, cecol)
	end

	return {
		lines = lines,
		selection = selection,
		csrow = csrow,
		cscol = cscol,
		cerow = cerow,
		cecol = cecol,
	}
end

return util
