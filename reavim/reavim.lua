reaper.ClearConsole()
local start_time = reaper.time_precise()
local last_focused = reaper.JS_Window_GetFocus()
local last_char = cmd

local timeout = .850
local stamina = 0
local kb = {main = {}, midi = {}}
local cmd_list = {}

function con(str) reaper.ShowConsoleMsg('\n' .. tostring(str)) end

function default_settings()
    file = io.open(script_path .. 'settings.conf', 'w')
    file:close()
end

function default_keybindings()
    file = io.open(script_path .. 'confs/' .. cmd .. '-kbs.conf', 'w')
    file:close()

end

function load_settings()
    local file = io.open(script_path .. 'settings.conf', 'r')
    if file == nil then
	default_settings()
	file = io.open(script_path .. 'settings.conf', 'r')
    end
end

function load_keybindings()
    local file = io.open(script_path .. 'confs/' .. cmd .. '-kbs.conf', 'r')
    if file == nil then
	default_keybindings()
	file = io.open(script_path .. 'confs/' .. cmd .. '-kbs.conf', 'r')
    end

    for line in file:lines() do
	if line == nil then break end
	if line:sub(1, 2) == '--' or line:sub(1, 1) == '' then goto pass end
	local context = line:sub(1, line:find(' ') - 1)
	line = line:gsub(context .. ' ', '')
	local key = line:sub(1, line:find(' ') - 1)
	cmds = line:gsub(key .. ' ', '')
	local temp_cmds = {}
	for c in cmds:gmatch('[^%s]+') do table.insert(temp_cmds, c) end
	if context == 'main:' then
	    table.insert(kb.main, {key, {temp_cmds}})
	elseif context == 'midi:' then
	    table.insert(kb.midi, {key, {temp_cmds}})
	end

	::pass::
    end
    file:close()
end

function ex_commands(cmds)
    reaper.PreventUIRefresh(1)
    for i, c in ipairs(cmds[2]) do
	local midi = false
	for i, cmd in ipairs(c) do
	    if cmd:sub(1, 1) == 'm' then
		midi = true
		cmd = cmd:sub(2)
	    end

	    if cmd:sub(1, 1) == '_' then
		cmd = reaper.NamedCommandLookup(cmd)
	    end

	    if midi then
		reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), cmd)
	    else
		reaper.Main_OnCommand(cmd, 0)
	    end
	    con('Executed cmd: ' .. cmd)
	end
    end
    reaper.PreventUIRefresh(-1)
end

function is_in_str(a, b)
    if b:find(a) then
	return true
    else
	return false
    end
end

function remove(ind, list) table.remove(list, ind) end

function check_cmds(q)

    for i, v in ipairs(cmd_list) do
	if not is_in_str(q, v[1]) then remove(i, cmd_list) end
    end

    if string.len(q) == stamina then
	return true
    else
	return false
    end
end 
function init()
    local lf_str = reaper.JS_Window_GetTitle(last_focused)
    con('Last Focused= ' .. lf_str)
    if lf_str == 'trackview' then
	cmd_list = kb.main
    elseif lf_str == 'midiview' then
	cmd_list = kb.midi
    else
	cmd_list = kb.main
    end

    local intercept_level = reaper.JS_VKeys_Intercept(-1, 0)
    reaper.JS_VKeys_Intercept(-1, -intercept_level)
    -- load_settings()
    load_keybindings()
    reaper.JS_VKeys_Intercept(-1, 1)

    stamina = find_longest_seq(cmd_list)

end

function find_longest_seq(cmd_list)
    local longest = 0
    for i, cmd in ipairs(cmd_list) do
	if string.len(cmd[1]) > longest then longest = string.len(cmd[1]) end
    end
    return longest
end

function onexit() 
    reaper.JS_VKeys_Intercept(-1, -1) 
    reaper.JS_Window_SetFocus(last_focused)
end

function get_char()
    local char = reaper.JS_VKeys_GetState(-1)
    for i = 1, 255 do if char:byte(i) ~= 0 then return i + 32 end end
    return nil
end

init()

function main()
    char = get_char()
    if char == nil then
	last_char = ''
    else
	char = string.char(char):lower()
	if char ~= last_char then
	    cmd = cmd .. char
	    last_char = char

	end
    end

    local exhausted = check_cmds(cmd)

    current_time = reaper.time_precise()

    if (current_time - timeout >= start_time) or exhausted then
	for i, c in ipairs(cmd_list) do
	    if c[1] == cmd then
		ex_commands(c)
	    end
	end

	local remaining = ''
	for i, c in ipairs(cmd_list) do
	    remaining = remaining .. ', ' .. c[1]
	end

	--+--+--+--+--+--+--+--+--+--+--
	-- Debugging
	--+--+--+--+--+--+--+--+--+--+--
	-- msg = '\nstamina= ' .. stamina
	-- msg = msg .. '\nexhausted= ' .. tostring(exhausted)
	-- msg = msg .. '\ncmd= -' .. cmd .. '-'
	-- msg = msg .. '\nremaining= ' .. remaining
	-- con(msg)
	reaper.atexit(onexit)
	return
    else
	reaper.defer(main)
    end
end

