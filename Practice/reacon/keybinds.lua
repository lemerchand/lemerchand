local b = string.byte
local esc = 27

local af = require('afuncs')

local Keybinds = {
    {
	name = 'showClog',
	modifier = { ctrl = true },
	key = 'l',
	commands = { func = af.showClog, args = {} },
    },
    {
	name = 'showTrackView',
	modifier = {alt = true, ctrl = true},
	key = 't',
	commands = { func = af.showTrackview, args = {} },
    },
    {
	name = 'Quit',
	modifier = {},
	key = esc,
	commands = { func = af.quit, args = {} },
    }
}

return Keybinds
