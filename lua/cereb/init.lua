local M = {}

local cmd = vim.cmd

local config = {}

function M.setup(user_options)
	config = vim.tbl_deep_extend("force", config, user_options)
end

return M
