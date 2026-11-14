local uv = vim.loop
local M = {}

function M.current_dir()
	return vim.fn.getcwd()
end
-- these codes are based on https://github.com/ahmedkhalf/project.nvim
function M.find_dir_which_has_patterns(patterns, max_ancestor_depth)
	local search_dir = vim.fn.getcwd()
	local last_dir_cache = ""
	local curr_dir_cache = {}

	local function get_parent(path)
		path = path:match("^(.*)/")
		if path == "" then
			path = "/"
		end
		return path
	end

	local function get_files(file_dir)
		last_dir_cache = file_dir
		curr_dir_cache = {}

		local dir = uv.fs_scandir(file_dir)
		if dir == nil then
			return
		end

		while true do
			local file = uv.fs_scandir_next(dir)
			if file == nil then
				return
			end

			table.insert(curr_dir_cache, file)
		end
	end

	local function has(dir, pattern)
		if last_dir_cache ~= dir then
			get_files(dir)
		end
		for _, file in ipairs(curr_dir_cache) do
			if file:match(pattern) ~= nil then
				return true
			end
		end
		return false
	end

	local function match(dir, pattern)
		return has(dir, pattern)
	end

	local ancestor_num = 0
	while true do
		for _, pattern in ipairs(patterns) do
			if match(search_dir, pattern) then
				return search_dir
			end
		end

		local parent = get_parent(search_dir)
		if parent == search_dir or parent == nil then
			return nil
		end

		ancestor_num = ancestor_num + 1
		if max_ancestor_depth ~= nil and ancestor_num >= max_ancestor_depth then
			return nil
		end

		search_dir = parent
	end
end

return M
