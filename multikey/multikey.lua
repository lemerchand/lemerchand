-- @version 1.05
-- @author Lemerchand
-- @provides
--    [main] .
-- @changelog
--    + Create debugging function
--    + Assess stamina after each keystroke (prevent uneccesary waiting) 
--    + Catch modifer keys
 

reaper.ClearConsole()
local settings = {
	debug = false,
	timeout = .850,
}

-- Collect dbg info from around the script for dbg function
local dbg_msg = {}

-- Retrieve the time in which the script was invoked
-- This will allow the timeout variable to terminate
-- the script.
local start_time = reaper.time_precise()

-- Stamina refers to how many potential keystrokes are left
-- eg., if you have pressed 3 keys and the longest binding is 3 char
-- long, there is no point in waiting any longer
local stamina = 0

-- Figure out the window it was called from
-- Useful for re-enabling it's focus at script termination
local last_focused = reaper.JS_Window_GetFocus()

-- This is the key the user pressed to invoke the script
local last_char = cmd

-- The bindings list will hold all of the bindings for various
-- targets, eg, allowing the user to trigger main commands in the ME
local bindings = {main = {}, midi = {}}

-- This will hold remaining potential bindings, ruling out those
-- that are no longer possible
local cmd_list = {}

function log(str) reaper.ShowConsoleMsg('\n' .. tostring(str)) end

function init()
	-- Determine the view of the most recently focused window
	-- TODO: Update this. Can it be done better, or does it just 
	-- need a more exhaustice list?
	local lf_str = reaper.JS_Window_GetTitle(last_focused)

	if lf_str == 'trackview' then
		cmd_list = bindings.main
	elseif lf_str:find('midi') then
		cmd_list = bindings.midi
	else
		cmd_list = bindings.main
	end

	-- get current intercept level, nullify it, then -1
	-- Without this major breakages can occur due to sub -1 lvls
	local intercept_level = reaper.JS_VKeys_Intercept(-1, 0)
	reaper.JS_VKeys_Intercept(-1, -intercept_level)
	reaper.JS_VKeys_Intercept(-1, 1)

	-- Read files
	load_settings()
	load_keybindings()

	-- Remove modifiers from cmd
	local mods = {'shift%-', 'ctrl%-', 'alt%-', 'meta%-'}
	for i, mod in ipairs(mods) do
		cmd = cmd:gsub(mod, '')
	end
end

-- XXX: This will generate a default settings file once that functionality
-- exists. 
function restore_default_settings()
	file = io.open(script_path .. '../settings.conf', 'w')
	for k, b in pairs(settings) do
		file:write(k .. '=' .. tostring(b) .. '\n')
	end
	file:close()
end

-- Creates an empty config file for the key in case there isn't one
function create_empty_keybindings_file()
	file = io.open(script_path .. '../bindings/' .. cmd .. '-Multikey-Bindings.conf', 'w')
	file:close()
end

-- convert pesky config file strings to bools and numbers
function convert_var(val)
	if val == 'true' then val = true 
	elseif val == 'false' then val = false 
	elseif val:match('%d+') then val = tonumber(val) 
	end
	return val
end

-- Load settings
function load_settings()
	local file = io.open(script_path .. '../settings.conf', 'r')
	if file == nil then
		restore_default_settings()
		file = io.open(script_path .. '../settings.conf', 'r')
	end
	for line in file:lines() do
		key_start, key_end = line:find('=')
		key = line:sub(1, key_start-1)
		val = line:sub(key_end+1)

		settings[key] = convert_var(val)

	end
end

-- This function loads the conf file of whatever key triggered the script
function load_keybindings()
	local file = io.open(script_path .. '../bindings/' .. cmd .. '-Multikey-Bindings.conf', 'r')
	if file == nil then
		create_empty_keybindings_file()
		file = io.open(script_path .. '../bindings/' .. cmd .. '-Multikey-Bindings.conf', 'r')
	end

	for line in file:lines() do
		-- Stop the loop upon EOF
		if line == nil then break end

		-- Ignore comments (--)
		if line:sub(1, 2) == '--' or line:sub(1, 1) == '' then goto pass end
		-- Get the target for the command (main, midi, media, etc)
		local target = line:sub(1, line:find(' ') - 1)
		line = line:gsub(target .. ' ', '')
		-- Get the key for the action and load them into 'cmds'
		local key = line:sub(1, line:find(' ') - 1)
		cmds = line:gsub(key .. ' ', '')
		local temp_cmds = {}
		-- Parse the commands and put them into a temp table to be inserted
		-- into the target's list
		for c in cmds:gmatch('[^%s]+') do table.insert(temp_cmds, c) end
		if target == 'all:' then
			table.insert(bindings.main, {key, {temp_cmds}})
			table.insert(bindings.midi, {key, {temp_cmds}})
		elseif target == 'main:' then
			table.insert(bindings.main, {key, {temp_cmds}})
		elseif target == 'midi:' then
			table.insert(bindings.midi, {key, {temp_cmds}})
		end
		-- Used for comments
		::pass::
	end
	file:close()
end

function execute_commands(cmds)
	reaper.PreventUIRefresh(1)
	for i, c in ipairs(cmds[2]) do
		local midi = false

		for i, cmd in ipairs(c) do
			-- Determine the target (for now just ME or main)
			if cmd:sub(1, 1) == 'm' then
				midi = true
				cmd = cmd:sub(2)
			end

			-- Determine if it's an SWS/Custom Action
			-- If so, perform lookup
			if cmd:sub(1, 1) == '_' then
				cmd = reaper.NamedCommandLookup(cmd)
			end

			if midi then
				reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), cmd)
			else
				reaper.Main_OnCommand(cmd, 0)
			end
		end
	end
	reaper.PreventUIRefresh(-1)
end

function is_in_str(a, b) return b:find(a) end

function remove(ind, list) table.remove(list, ind) end

-- Remove commands that are no longer possible
-- return true if there cannot be more keystrokes
function check_cmds(q)

	for i, v in ipairs(cmd_list) do
		if not is_in_str(q, v[1]) then remove(i, cmd_list) end
	end

	-- Set the base stamina to the longest seq of keys
	stamina = find_longest_seq(cmd_list)

	if string.len(q) == stamina then
		return true
	else
		return false
	end
end 

-- Looks for the longest string of chars possible to determine
-- stamina. TODO: Update this to run after every key stroke
function find_longest_seq(cmd_list)
	local longest = 0
	for i, cmd in ipairs(cmd_list) do
		if string.len(cmd[1]) > longest then longest = string.len(cmd[1]) end
	end
	return longest
end

-- JS API get char. Does not distinguish between upper/lwr 
-- hence +32
function get_char()
	local char = reaper.JS_VKeys_GetState(-1)
	for i = 1, 255 do if char:byte(i) ~= 0 then return i + 32 end end
	return nil
end

function debug()
	-- Remaining possibilities
	local remaining = ''
	for i, c in ipairs(cmd_list) do
		remaining = remaining .. '\n\t\t' .. c[1] 
	end

	-- --+--+--+--+--+--+--+--+--+--+--
	-- Debugging
	-- --+--+--+--+--+--+--+--+--+--+--
	msg = 'Last Focus=\t' .. reaper.JS_Window_GetTitle(last_focused)
	msg = msg .. '\nTimeout=\t' .. settings.timeout
	msg = msg .. '\nStamina=\t' .. stamina
	msg = msg .. '\nExhausted=\t' .. tostring(exhausted)
	msg = msg .. '\nExecuted cmd=\t' .. cmd
	msg = msg .. '\nTime Lapse=\t' .. current_time - start_time
	msg = msg .. '\nRemaining=' .. remaining
	log(msg)
end

-- Restore intercept lvl and last focused window
function onexit() 
	reaper.JS_VKeys_Intercept(-1, -1) 
	reaper.JS_Window_SetFocus(last_focused)
	if settings.debug then 
		debug()
	end

end

-- -- -- -- -- -- -- -- -- -- --
-- MAIN PROGRAM
-- -- -- -- -- -- -- -- -- -- --
init()

function main()
	local char = get_char()
	-- Don't allow repeating of chars due to keys being held
	if char == nil then
		last_char = ''
	else
		char = string.char(char):lower()
		-- BUG: This removes the 0, 1, or 2 from the keycode 
		-- I anticipate needign to change this to use GetMouseMods
		-- Or at the very least, sub %d for ''  ONLY if it's paired with 
		-- a char
		char = char:gsub('%d', '')
		if char ~= last_char then
			-- if it's a new key add it to the strokes
			cmd = cmd .. char
			last_char = char
		end
	end

	-- Check which cmds can be removed
	-- Also see if there can be anymore presses
	local exhausted = check_cmds(cmd)

	-- Get the time again, check if it's met the timeout threshold
	current_time = reaper.time_precise()
	if (current_time - settings.timeout >= start_time) or exhausted then
		-- At timeout or exhaustion, run the commands for the select keystroke
		for i, c in ipairs(cmd_list) do
			if c[1] == cmd then
				execute_commands(c)
			end
		end

		reaper.atexit(onexit)
		return
	else
		reaper.defer(main)
	end
end

