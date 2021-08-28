
--   ___  _______  _________  _  __
--  / _ \/ __/ _ |/ ___/ __ \/ |/ /
-- / , _/ _// __ / /__/ /_/ /    /
--/_/|_/___/_/ |_\___/\____/_/|_/
--
-- TODO: Parse spaces out to avoid dumb shit

Script = {
    name      =   'reacon',
    version   =   '.01',
    path      =   debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]],
    quit      =   false,
    debug     =   true
}

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../../libs/?.lua;".. package.path
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."libs/?.lua;".. package.path

require('aux_functions')
require('ui')
local command_list    =   require('commands')
local user_settings   =   require('Settings')
local kb              =   require('Keybinds')
local std             =   require('liblemerchand')
local af              =   require('afuncs')

--Aliases
local tbl      =   std.table
local dbg      =   std.dbg
local r        =   reaper
local format   =   string.format
local window   =   user_settings.window


local settings = {
    win = {
	width                 =   500,
	height                =   400,
	PAD                   =   {X   =   16, Y   =   28},
	context               =   user_settings.context or 'TRACKVIEW',
	unfocused_norefresh   =   window.unfocused_norefresh or false,
	refresh_rate          =   Adjust_ms_for_cycles(window.refresh_rate) or 1000,
	last_refresh          =   0,
    },
    keybinds = {
	repeat_delay          =   user_settings.repeat_delay or 2,
	repeat_speed          =   user_settings.repat_speed or .5,
    }
}

local FMIN, FMAX = r.ImGui_NumericLimits_Float()
r.ClearConsole()

ctx = r.ImGui_CreateContext(Script.name)
r.ImGui_SetNextWindowSize(ctx, settings.win.width, settings.win.height)

c = Clog('clog', nil)
kb = Fill_out_kb_mods(kb)

local info        =   TextDisplay('info','')
local prompt      =   InputBox('prompt','')
local trackView   =   TrackView('trackView')


--  __ _  ___ _(_)__
-- /  ' \/ _ `/ / _ \
--/_/_/_/\_,_/_/_//_/
--
--TODO:
--	* Figure out how to capture <es> and <return>
--	*

local manifest = Create_manifest()

local function main()
    -- If norefresh -> prevent manifest from refreshing when window unfocused
    local window_is_focused
    if settings.win.unfocused_norefresh then
	 window_is_focused = reaper.ImGui_IsWindowFocused(ctx, r.ImGui_FocusedFlags_RootAndChildWindows())
    else
	 window_is_focused = true
    end

    -- If window focused, or norefresh == false, update manifest according to
    -- refresh_rate setting
    if window_is_focused then
	settings.win.last_refresh = settings.win.last_refresh + 1
	if settings.win.last_refresh  >= settings.win.refresh_rate then
	    settings.win.last_refresh = 0
	    manifest = Create_manifest()
	end
    end

    -- Anything between this and Pop will have full width
    local window_width = r.ImGui_GetWindowWidth(ctx) - settings.win.PAD.X
    r.ImGui_PushItemWidth(ctx, window_width)

    -- Set up the input prompt
    local posy = r.ImGui_GetWindowHeight(ctx) - settings.win.PAD.Y
    r.ImGui_SetCursorPosY(ctx, posy)
    local returned_text = prompt:Draw()
    if r.ImGui_IsWindowAppearing(ctx) then r.ImGui_SetKeyboardFocusHere(ctx, -1) end

    -- If enter pressed, refocus prompt, and process the text
    if returned_text then
	r.ImGui_SetKeyboardFocusHere(ctx, -1)

	-- Look to see if the user entered a valid cmd... if so then run 'em
	local commands = Find_command(returned_text, command_list)
	if commands then
	    dbg('Text entered...')
	    Execute_commands(commands, settings.win)
	end
    end

    -- Prepare display
    r.ImGui_SetCursorPosY(ctx, settings.win.PAD.Y)
    local display_height = posy - (1.25 * settings.win.PAD.Y)

    -- Apply preparations to the appropriate context
    local display = nil
    local display_data = nil
    if settings.win.context     == 'INFO' then
	display         = info
	display_data    = ''
    elseif settings.win.context == 'TRACKVIEW' then
	display         = trackView
	display_data    = manifest
    elseif settings.win.context == 'CLOG' then
	display         = c
	display_data    = nil
    end

    r.ImGui_BeginChildFrame(ctx, '##displayframe', window_width, display_height)
    -- Draw the UI for the given context
    display.height         =   display_height - (settings.win.PAD.Y // 4)
    display.width          =   window_width - (settings.win.PAD.X // 2)
    local display_change   =   display:Draw(display_data)
    r.ImGui_EndChildFrame(ctx)

    -- Process changes made to UI elements here
    -- The prompt is handled separately (see above) because refocusing it
    -- relies on proxmity (a la ImGui_SetKeyboardFocusHere())
    if display_change then
	if settings.win.context      ==  'TRACKVIEW' then trackView:Update(display_change)
	elseif settings.win.context  ==  'INFO' then info:Update(display_change)
	elseif settings.win.context  ==  'CLOG' then c:Update(display_change)
	end

	-- Only update the effected track
	manifest[display_change.track + 1] = Get_track_info(r.GetTrack(0, display_change.track ))
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
	    local match_found, match = Find_keybind_match(mods, char, kb)
	    if match_found then
		dbg('Keybind match found...')
		Execute_keybinding(match, command_list, settings.win)
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

