
--   ___  _______  _________  _  __
--  / _ \/ __/ _ |/ ___/ __ \/ |/ /
-- / , _/ _// __ / /__/ /_/ /    /
--/_/|_/___/_/ |_\___/\____/_/|_/
--
-- TODO: Active widget defaults to prompt
-- TODO: Refresh tracks occasionally without change
--	 - I hope to reduce CPU by not refreshing the manifest every cycle
--

Script = {
    name     = 'reacon',
    version  = '.01',
    path     = '',
    quit     = false,
    debug    = true
}

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../../libs/?.lua;".. package.path
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."libs/?.lua;".. package.path

require('aux_functions')
require('ui')
local command_list = require('commands')
local settings     = require('Settings')
local kb           = require('Keybinds')
local std          = require('liblemerchand')
local af           = require('afuncs')

--Aliases
local tbl = std.table
local dbg = std.dbg
local r   = reaper
local format = string.format

local win = {
    width    = 500,
    height   = 400,
    PAD      = {X=16, Y=28},
    context  = 'CLOG',
}

local FMIN, FMAX = r.ImGui_NumericLimits_Float()
r.ClearConsole()

ctx = r.ImGui_CreateContext(Script.name)
r.ImGui_SetNextWindowSize(ctx, win.width, win.height)

c = Clog('clog', nil)
kb = Fill_out_kb_mods(kb)

local info	= TextDisplay('info','')
local prompt	= InputBox('prompt','')
local trackView = TrackView('trackView')


--  __ _  ___ _(_)__
-- /  ' \/ _ `/ / _ \
--/_/_/_/\_,_/_/_//_/
--
--TODO:
--	* Figure out how to capture <es> and <return>
--	*

local manifest = Create_manifest()

local function main()
    -- Anything between this and Pop will have full width
    local window_width = r.ImGui_GetWindowWidth(ctx) - win.PAD.X
    r.ImGui_PushItemWidth(ctx, window_width)

    -- Set up the input prompt
    local posy = r.ImGui_GetWindowHeight(ctx) - win.PAD.Y
    r.ImGui_SetCursorPosY(ctx, posy)
    local returned_text = prompt:Draw()
    -- If enter pressed, refocus prompt, and process the text
    if returned_text then
	r.ImGui_SetKeyboardFocusHere(ctx, -1)

	-- Look to see if the user entered a valid cmd... if so then run 'em
	local commands = prompt:Find_command(returned_text, command_list)
	if commands then
	    dbg('Text entered...')
	    Execute_commands(commands, win)
	end
    end

    -- Prepare display
    r.ImGui_SetCursorPosY(ctx, win.PAD.Y)
    local display_height = posy - (1.25 * win.PAD.Y)

    -- Apply preparations to the appropriate context
    local display = nil
    local display_data = nil
    if win.context     == 'INFO' then
	display         = info
	display_data    = ''
    elseif win.context == 'TRACKVIEW' then
	display         = trackView
	display_data    = manifest
    elseif win.context == 'CLOG' then
	display         = c
	display_data    = nil
    end

    r.ImGui_BeginChildFrame(ctx, '##displayframe', window_width, display_height)
    -- Draw the UI for the given context
    display.height = display_height - (win.PAD.Y // 4)
    display.width  = window_width - (win.PAD.X // 2)
    local change = display:Draw(display_data)

    r.ImGui_EndChildFrame(ctx)
    -- Process changes made to UI elements here
    -- The prompt is handled separately (see above) because refocusing it
    -- relies on proxmity (a la ImGui_SetKeyboardFocusHere())
    if change then
	if win.context == 'TRACKVIEW' then trackView:Update(change)
	elseif win.context == 'INFO' then info:Update(change)
	elseif win.context == 'CLOG' then c:Update(change)
	end
	-- Update the tracks -- there has been a change!
	manifest = Create_manifest()
    end

    -- Identify the key and modifiers being pressed, if any
    local char = Get_key()
    local mods = Get_modifiers()


    -- If a key *is* being pressed, then let's do some work
    if char ~= 0 then
	-- Check to make sure the key isn't being repeated due to a hold-down
	local amt = r.ImGui_GetKeyPressedAmount(
	    ctx,
	    char,
	    settings.keybinds.repeat_delay,
	    settings.keybinds.repeat_speed
	    )
	if amt >= 1 then
	    local match_found, action = Find_keybind_match(mods, char, kb)
	    if match_found then
		dbg('Keybind match found...')
		Execute_commands(action, win)
	    end

	end
    end
    -- End this frame
    r.ImGui_PopItemWidth(ctx)
    r.ImGui_End(ctx)
end

--   __
--  / /__  ___  ___
-- / / _ \/ _ \/ _ \
--/_/\___/\___/ .__/
--           /_/
local function loop()
    local visible, running = r.ImGui_Begin(ctx, "Reacon", true)

    if visible then main() end

    if running and not Script.quit then r.defer(loop)
    else r.ImGui_DestroyContext(ctx)


    end
end

loop()

