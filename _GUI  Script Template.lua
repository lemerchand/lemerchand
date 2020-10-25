-------------------------------------------------------------------------------
--						SCRIPT NAME
-------------------------------------------------------------------------------
--  Modified: 2020.10.20 at 5am
--
--	TODO: 
-- 		+ 
-- 		+
--		+
--
-- RECENT CHANGES:
--		+ 
--		+
--		+
--
--
--- KNOWN ISSUES:
--		+ 
--		+ 
------------------------------------------------------------------------------
local _version = .95
local _name = "Script Name"


--Load UI Library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
--Remove "../" if inn the same dir
reaperDoFile('../ui.lua')
reaperDoFile('../cf.lua')

---------------------
--Window Mngmt--------
----------------------
--Get current midi window so it can refocus on it when script terminates

local lastWindow = reaper.JS_Window_GetFocus()


--Open window at mouse position--
local mousex, mousey = reaper.GetMousePosition()
gfx.init(_name .. " " .. _version, 248, 630, false, mousex+150, mousey-125)

-- Keep on top
local win = reaper.JS_Window_Find(_name .. _version, true)
if win then reaper.JS_Window_AttachTopmostPin(win) end



----------------------
--MAIN PROGRAM--------
----------------------

reaper.Undo_BeginBlock()

function main()

	fill_background()
	-- Get Kestrokes
	char = gfx.getchar()

	-- Deal with key stokes
	-- If char == ESC then close window`
	if char == 27 or char == -1  then 
		reaper.atexit(reaper.JS_Window_SetFocus(lastWindow))
		return
	-- Otherwise keep window open
	else reaper.defer(main) end




end

main()
reaper.Undo_EndBlock(_name .. "", -1)