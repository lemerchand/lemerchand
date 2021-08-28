local b = string.byte
local esc = 27

local af = require('afuncs')

local Keybinds = {
    {
	name = 'showLog',
	modifier = { ctrl = true },
	key = 'l',
	commands = { 'showLog'},
    },
    {
	name = 'showTrackView',
	modifier = {alt = true, ctrl = true},
	key = 't',
	commands = { 'showTrackview' },
    },
    {
	name = 'exit',
	modifier = {},
	key = esc,
	commands = { 'exit' },
    }
}

return Keybinds
