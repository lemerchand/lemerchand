local r        =   reaper
local std      =   require('liblemerchand')
local tbl      =   std.table
local dbg      =   std.dbg
local format   =   string.format

function Adjust_ms_for_cycles(n) return n * .033 end

function Create_manifest()
    local manifest = {}
    local track_count = r.CountTracks(0)
    for t = 0, track_count - 1 do
	local track = r.GetTrack(0, t)
	table.insert(manifest, Get_track_info(track))
    end
    dbg('Manifest Created')
    return manifest
end

-- Why use 're?' local r = reaper, recall?
function Convert_native_to_hex(track_color)
    local re, g, b = r.ColorFromNative(track_color)
    return RGB_to_HEX(re, g, b, 255)
end

function RGB_to_HEX(re, g, b, a)
    local red     =   re * 256 * 256 * 256
    local green   =   g * 256 * 256
    local blue    =   b * 256

    return red + green + blue + a
end

function Get_track_info(track)
    local entry = {}

    _, entry.name     =   r.GetSetMediaTrackInfo_String(track, 'P_NAME', '', false )
    entry.number      =   math.floor(r.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER') - 1)
    entry.color       =   r.GetTrackColor(track)
    entry.input       =   r.GetMediaTrackInfo_Value(track, 'I_RECINPUT')
    entry.auto_mode   =   r.GetMediaTrackInfo_Value(track, 'I_AUTOMODE')
    entry.pan         =   r.GetMediaTrackInfo_Value(track, 'D_PAN')
    entry.parent      =   r.GetMediaTrackInfo_Value(track, 'P_PARTRACK')

    -- BOOLEANS
    if r.GetMediaTrackInfo_Value(track, 'B_MUTE') == 1 then
	entry.muted  = true
    else entry.muted = false
    end
    if r.GetMediaTrackInfo_Value(track, 'I_SOLO') == 1 then
	entry.soloed = true
    else
	entry.soloed = false
    end
    if r.GetMediaTrackInfo_Value(track, 'I_RECARM') == 1 then
	entry.armed  = true
    else entry.armed = false
    end
    if r.GetMediaTrackInfo_Value(track, 'B_PHASE') == 1 then
	entry.phase_inverted  = true
    else entry.phase_inverted = false
    end
    if r.GetMediaTrackInfo_Value(track, 'I_FXEN') == 1 then
	entry.fx_enabled  = true
    else entry.fx_enabled = false
    end
    if r.GetMediaTrackInfo_Value(track, 'I_RECMON') == 1 then
	entry.monitored  = true
    else entry.monitored = false
    end
    if r.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH') == 1 then
	entry.is_a_parent  = true
    else entry.is_a_parent = false
    end
    -- XXX: Avoid devestation by way of Master Track
    if entry.number == -1 then
	entry.in_mixer = nil
	entry.in_tcp   = nil
    else
	if r.GetMediaTrackInfo_Value(track, 'B_SHOWINMIXER') == 1 then
	    entry.in_mixer  = true
	else entry.in_mixer = false
	end
	if r.GetMediaTrackInfo_Value(track, 'B_SHOWINTCP') == 1 then
	    entry.in_tcp  = true
	else entry.in_tcp = false
	end
	if r.GetMediaTrackInfo_Value(track, 'I_PLAY_OFFSET') == 1 then
	    entry.offset  = true
	    entry.offset  = r.GetMediaTrackInfo_Value(track, 'I_PLAY_OFFSET')
	else entry.offset = false
	end
    end

    return entry
end

local backspace  =  8   ;  local tab   =  9   ;  local enter  =  13  ;  local esc  =  27
local space      =  32  ;  local home  =  36  ;  local end_   =  35

local maxkey =  512
local minkey =  20

function Get_key()
    for i = minkey, maxkey - 1 do
	if r.ImGui_IsKeyDown(ctx, i) then
	    return i
	end
    end
    return 0
end

function Get_modifiers()
    local mods =  {meta=nil, shift=nil, ctrl=nil, alt=nil}
    mods.shift =  r.ImGui_GetKeyMods(ctx)  &  r.ImGui_KeyModFlags_Shift()  ~= 0
    mods.ctrl  =  r.ImGui_GetKeyMods(ctx)  &  r.ImGui_KeyModFlags_Ctrl()   ~= 0
    mods.alt   =  r.ImGui_GetKeyMods(ctx)  &  r.ImGui_KeyModFlags_Alt()    ~= 0
    mods.meta  =  r.ImGui_GetKeyMods(ctx)  &  r.ImGui_KeyModFlags_Super()  ~= 0
    return mods
end

function Find_keybind_match(mods, char, kb)
    local possible_binds = tbl.clone(kb)
    local nchar = char
    char = string.lower(string.char(char))

    local modstring = ''

    if Script.debug then
	if mods.ctrl  then  modstring  =  modstring .. 'Ctrl '  end
	if mods.alt   then  modstring  =  modstring .. 'Alt '   end
	if mods.shift then  modstring  =  modstring .. 'Shift ' end
	if mods.meta  then  modstring  =  modstring .. 'Super'  end
	if modstring == '' then modstring = 'None' end
    end

    dbg('Char = %s (%s)\nMods = %s', false, char, nchar, modstring)


    for k, v in pairs(possible_binds) do
	if (v.key ~= char) and (v.key ~= nchar) then possible_binds[k] = nil end
    end


    for k, v in pairs(possible_binds) do
	dbg('key b = ' .. v.key)
	if tbl.are_equal(mods, v.modifier) then
	    return true, v.commands
	end
    end
end

function Find_command(change, commands_list)
    dbg('Searching for commands...')
    for _, v in pairs(commands_list) do
	if tbl.has_value(v.triggers, change) then 
	    dbg('...found %s!', false, change)
	return v.commands end
    end
    dbg('None found!')
    return false
end

function Execute_keybinding(keybind, command_list, win)
    for k, v in pairs(keybind) do 
	local commands = Find_command(v, command_list)
	Execute_commands(commands, win)
    end
end

function Execute_commands(commands, win)
    local succeeded, _ = pcall(commands.func, win, table.unpack(commands.args))
    if not succeeded then r.ShowMessageBox(
	    'This command failed...' ..
	    '\n\nCheck your commands.lua for typos, ' ..
	    'missing arguments, and other gremlins.',
	    'Oh no, an error!', 0
	    )
    end
end

function Fill_out_kb_mods(kb)
    local modkeys = {alt = true, ctrl = true, shift = true, meta = true}
    for _, v in pairs(kb) do
	for kk, _ in pairs(modkeys)  do
	    if not v.modifier[kk] then v.modifier[kk] = false end
	end
    end
    return kb
end
