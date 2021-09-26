-- TODO: Find a way to take arguments from the commands line with a wild card....
--   Eg: `quit bloppity` - > args = {'*'}
--
local af = require('afuncs')

local commands = {
    -- Exit the program
    {
	name = 'Exit',
	context      =  nil,
	description  =  'Exits the program.',
	triggers     =  {'exit', 'quit', 'leavemealone'},
	commands     =  { func = af.quit, args = {} }
    },

    -- Show the trackView
    {
	name = 'ShowTrackview',
	context     = 'TRACKVIEW',
	description = 'Switches to the trackview.',
	triggers    = {'showTrackview' },
	commands    = { func = af.showTrackview, args = {} }
    },
    {
	name = 'Show Log',
	context     = 'CLOG',
	triggers    = {'showLog', 'showClog'},
	commands    = {func = af.showClog, args = {} }
    },
    {
	name = 'Edit Settings.',
	context     = nil,
	triggers    = {'edit SETTINGS', 'e SETTINGS'},
	commands    = { func = af.openExternal, args = {} }
    },
    {
	name = 'track',
	context     = 'TRACKVIEW',
	triggers    = { 'track', 'tr' },
	commands    = { }
    }
}

return commands

