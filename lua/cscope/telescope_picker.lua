local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config")
local make_entry = require("telescope.make_entry")
local entry_display = require "telescope.pickers.entry_display"
local utils = require("telescope.utils")

local make_from_cscope = function(entry)
	local items = {
		{ width = 30 },
		{ remaining = true },
	}
	local displayer = entry_display.create { separator = "▏", items = items }

	local make_display = function(entry)
		local input = {}
		table.insert(input, string.format("%s:%s", utils.transform_path({}, entry.filename), entry.lnum))

		local text = entry.text
		text = text:gsub(".* | ", "")
		table.insert(input, text)

		return displayer(input)
	end

	return function(entry)
		return make_entry.set_default_entry_mt({
				value = entry,
				ordinal = entry.filename .. " " .. entry.text,
				display = make_display,

				filename = entry.filename,
				lnum = tonumber(entry.lnum),
				text = entry.text,
			}, {})
	end
end

local finder = nil
local prompt_title = nil

M.prepare = function(cscope_parsed_output, telescope_title)
	finder = finders.new_table({
			results = cscope_parsed_output,
			entry_maker = make_from_cscope()
		})

	prompt_title = telescope_title
end

M.run = function(opts)
	opts = opts or {}
	opts.entry_maker = entry_maker

	pickers
		.new(opts, {
			prompt_title = prompt_title,
			finder = finder,
			previewer = config.values.grep_previewer(opts),
			sorter = config.values.generic_sorter(opts),
		})
		:find()
end

return M
