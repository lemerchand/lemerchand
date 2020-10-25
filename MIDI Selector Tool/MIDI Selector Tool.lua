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
local _version = " v.95"
local _name = "MST3K"


--Load UI Library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')

---------------------
--Window Mngmt--------
----------------------
--Get current midi window so it can refocus on it when script terminates

local lastWindow = reaper.JS_Window_GetFocus()


--Open window at mouse position--
local mousex, mousey = reaper.GetMousePosition()
gfx.init(_name .. " " .. _version, 248, 630, false, mousex+165, mousey-265)

-- Keep on top
local win = reaper.JS_Window_Find(_name .. _version, true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

----------------------
--Help Text-----------
---------------------
local htSelect			= "Select notes based on settings.\nR-click restricts to time selection.\nShift+L-click to invert filter."
local htClear 			= "Clear Selection. \nR-click for global reset.\nHotkeys: (Shift+) Backspace"
local htCapture 		= 'Set parameters from selected notes.\nOr Shift+L-Click a parameter.'
local htMinNote 		= "Set minimum velocity.\nR-click to reset."
local htMaxNote 		= "Set maximum velocity.\nR-click to reset."
local htPitchTgl 		= "Toggles pitches.\nR-click to reset.\nCtrl+L-click: exclusive select."


----------------------
--Midi Note Thangs-----------
---------------------
local note_midi_n = {0,1,2,3,4,5,6,7,8,9,10,11}			--Covers all 12 notes (pitch%12)
local note_names = {'C','C#', 'D', 'D#', 'E',				--Note names for notes_list
			'F','F#', 'G', 'G#', 'A', 
			'A#','B'}




----------------------
--MAIN PROGRAM--------
----------------------
reaper.Undo_BeginBlock()

----------------------
--Create Elements-----
----------------------


--General Frame
local frm_general = Frame:Create(10, 12, 227, 90, "GENERAL")

local btn_select = Button:Create(frm_general.x+10, frm_general.y+30, "Select", htSelect)
local btn_clear = Button:Create(btn_select.x, btn_select.y + btn_select.h + 10, "Clear", htClear)
local btn_capture = Button:Create(btn_select.x + btn_select.w + 10, btn_select.y, "Capture", htCapture)

--Pitch frame
local frm_pitch = Frame:Create(10, frm_general.y + frm_general.h + 27, 227, 110, "PITCH")


local ib_maxNote = InputBox:Create(frm_pitch.x + 178, frm_pitch.y + 30, "G10", htMaxNote)
local ib_minNote = InputBox:Create(frm_pitch.x + 75, frm_pitch.y + 30, "C0", htMinNote, ib_maxNote.w)
local group_noteRange ={ib_minNote, ib_maxNote}

local lbl_minNote = Text:Create(ib_minNote.x - 60, ib_minNote.y + 7, "Lowest:")
local lbl_maxNote = Text:Create(ib_maxNote.x - 63, ib_maxNote.y + 7, "Highest:")

local tgl_pitch = {}
local pitchTglOffset = frm_pitch.x+20
local group_pitchToggles = {}
for pe = 1, 6 do
	 tgl_pitch[pe] = Toggle:Create(frm_pitch.x + pitchTglOffset, frm_pitch.y+60, note_names[pe], htPitchTgl, 20, 25)
	 pitchTglOffset = pitchTglOffset + 28
	 table.insert(group_pitchToggles, tgl_pitch[pe])
end

pitchTglOffset = frm_pitch.x+20
for pe = 7, 12 do
	 tgl_pitch[pe] = Toggle:Create(frm_pitch.x + pitchTglOffset, frm_pitch.y+86, note_names[pe], htPitchTgl, 20, 25)
	 pitchTglOffset = pitchTglOffset + 28
	 table.insert(group_pitchToggles, tgl_pitch[pe])
end


--Velocity Frame
local frm_velocity = Frame:Create(10, frm_pitch.y + frm_pitch.h + 27, 227,85, "VELOCITY")


--Beats fFrame
local frm_beats = Frame:Create(10, frm_velocity.y + frm_velocity.h + 27, 227, 115, "BEATS")


--Status bar
--For now status needs to be global
status = Status:Create(10, frm_beats.y + frm_beats.h + 27, 227, 60, "INFO", nil, nil, "Hover over a control for more info!")




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

	--Draw Elements
	group_exec(Elements, 'draw')


	--Reset pitches on right click
	for p, pp in ipairs(group_pitchToggles) do
		if pp.rightClick then group_exec(group_pitchToggles, 'reset') end
	end

	--Reset note ranges on right click
	if ib_minNote.rightClick or ib_maxNote.rightClick then group_exec(group_noteRange, 'reset') end

end

main()
reaper.Undo_EndBlock(_name .. "", -1)