-------------------------------------------------------------------------------
--						SCRIPT NAME
-------------------------------------------------------------------------------
--  Modified: 2020.10.26 at 09:57
--	TODO: 
-- 		+ Setup save file for beats/settings
-- 		+ Spruce up the logic for the mutual sliding effect
--		+ Fill up space/ improve UI
--
-- RECENT CHANGES:
--		+ Moved over to new GUI lib
--		+ Section-specific capture
--		+ Toggle button swipe
--
--
--- KNOWN ISSUES:
--		+ 
--		+ 
------------------------------------------------------------------------------
local _version = " v.98"
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
local dockOnStart = get_settings(reaper.GetResourcePath() .. '/Scripts/lemerchand/MIDI Selector Tool/lament.config') 
if dockOnStart == "1" then dockOnStart = true else dockOnStart = false end
--Open window at mouse position--
local mousex, mousey = reaper.GetMousePosition()
gfx.init(_name .. " " .. _version, 248, 630, dockOnStart, mousex+165, mousey-265)

-- Keep on top
local win = reaper.JS_Window_Find(_name .. " " .. _version, true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

----------------------
--Help Text-----------
---------------------
local htSelect			= "Select notes based on settings.\nR-click: select in time selection.\nShift+L-click to invert filter."
local htClear 			= "Clear Selection. \nR-click for global reset.\nHotkeys: (Shift+) Backspace"
local htCapture 		= "Set parameters from selected notes.\nOr Shift+L-Click a parameter to\ncapture only that."
local htMinNote 		= "Sets lowest possible note.\nR-click to reset."
local htMaxNote 		= "Sets highest possible note.\nR-click to reset."
local htPitchTgl 		= "Toggles pitches.\nR-click to reset.\nCtrl+L-click: exclusive select."
local htVelSlider		= "Sets the lowest/highest velocity.\nR-click to reset.\nCtrl+L-click to slide both (beta)"
local htbeatsTgl		= "Include/exclude specific beats.\nR-click to reset.\nCtrl+L-click: exclusive select."
local htDockOnStart		= "Enable to dock MST3K when summoned."
local htMainTab			= "Main Controls."
local htSettingsTab 	= "General Settings."
-------------------------------
--Midi Note and BeatsThangs---
-------------------------------
note_midi_n = {0,1,2,3,4,5,6,7,8,9,10,11}			--Covers all 12 notes (pitch%12)
note_names = {'C','C#', 'D', 'D#', 'E',				--Note names for notes_list
			'F','F#', 'G', 'G#', 'A', 
			'A#','B'}

function default_vars()
	selectedNotes = {1,1,1,1,1,1,1,1,1,1,1,1}
	beats = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
end

default_vars()

--PPQ values for 16th notes
beats_in_ppq = {0,240,480,720,960,1200,1440,1680,1920,2160,2400,2640,2880,3120,3360,3600}
beats_as_ppq = {}



----------------------
--MAIN PROGRAM--------
----------------------
reaper.Undo_BeginBlock()

----------------------
--Create Elements-----
----------------------


--General Frame
local frm_general = Frame:Create(10, 12, 227, 90, "GENERAL       ")

local btn_select = Button:Create(frm_general.x+10, frm_general.y+30, "Select", htSelect)
local btn_clear = Button:Create(btn_select.x, btn_select.y + btn_select.h + 10, "Clear", htClear)
local btn_capture = Button:Create(btn_select.x + btn_select.w + 10, btn_select.y, "Capture", htCapture)

btn_select.hide = true
btn_clear.hide = true
btn_capture.hide = true

local tgl_dockOnStart = Toggle:Create(frm_general.x +10, frm_general.y + 30, "", htDockOnStart, dockOnStart, 10, 10)
local txt_dockOnStart = Text:Create(tgl_dockOnStart.x+20, tgl_dockOnStart.y, "Dock on start")


local tab_main = Tabs:AddTab("Main", true, htMainTab)
tab_main_elements = {btn_select, btn_clear, btn_capture}
frm_general:AttatchTab(tab_main)
tab_main:AttatchElements(tab_main_elements)

local tab_settings = Tabs:AddTab("Settings", false, htSettingsTab)
tab_settings_elements = {tgl_dockOnStart, txt_dockOnStart}
frm_general:AttatchTab(tab_settings)
tab_settings:AttatchElements(tab_settings_elements)






--Pitch frame
local frm_pitch = Frame:Create(10, frm_general.y + frm_general.h + 27, 227, 100, "PITCH")

local ib_maxNote = InputBox:Create(frm_pitch.x + 10, frm_pitch.y + 41, "G10", htMaxNote)
local ib_minNote = InputBox:Create(frm_pitch.x + 10, frm_pitch.y + 70, "C0", htMinNote, ib_maxNote.w)
local group_noteRange ={ib_minNote, ib_maxNote}

local lbl_minNote = Text:Create(ib_minNote.x+4, ib_minNote.y + 24, "MAX")
local lbl_maxNote = Text:Create(ib_maxNote.x+4, ib_maxNote.y -13, "MIN")



local tgl_pitch = {}
local pitchTglOffset = frm_pitch.x+42
local group_pitchToggles = {}

for pe = 1, 6 do
	 tgl_pitch[pe] = Toggle:Create(frm_pitch.x + pitchTglOffset, frm_pitch.y+41, note_names[pe], htPitchTgl, true, 25, nil)
	 pitchTglOffset = pitchTglOffset + 28
	 table.insert(group_pitchToggles, tgl_pitch[pe])
end

pitchTglOffset = frm_pitch.x+42
for pe = 7, 12 do
	 tgl_pitch[pe] = Toggle:Create(frm_pitch.x + pitchTglOffset, frm_pitch.y+67, note_names[pe], htPitchTgl, true, 25, nil)
	 pitchTglOffset = pitchTglOffset + 28
	 table.insert(group_pitchToggles, tgl_pitch[pe])
end

--Velocity Frame
local frm_velocity = Frame:Create(10, frm_pitch.y + frm_pitch.h + 27, 227,90, "VELOCITY")

local sldr_minVel = H_slider:Create(frm_velocity.x + 10, frm_velocity.y + 30, frm_velocity.w - 20, nil,"Min Velocity", htVelSlider, 0, 127, 0, false)
local sldr_maxVel = H_slider:Create(sldr_minVel.x, sldr_minVel.y + sldr_minVel.h + 10, sldr_minVel.w, nil,  "Min Velocity", htVelSlider, 0, 127, 127, true)
group_velSliders = {sldr_minVel, sldr_maxVel}



--Beats fFrame
local frm_beats = Frame:Create(10, frm_velocity.y + frm_velocity.h + 27, 227, 128, "BEATS")

local tgl_beats = {}
local beatsTglOffset = frm_beats.x+74
local group_beatsToggles = {}


for be = 1, 4 do
	 tgl_beats[be] = Toggle:Create(frm_beats.x + beatsTglOffset, frm_beats.y+30, be, htbeatsTgl, 20, 25)
	 beatsTglOffset = beatsTglOffset + 28
	 table.insert(group_beatsToggles, tgl_beats[be])
	 beats[be] = 0
end

beatsTglOffset = frm_beats.x+74
for be = 5, 8 do
	 tgl_beats[be] = Toggle:Create(frm_beats.x + beatsTglOffset, frm_beats.y+56, be, htbeatsTgl, 20, 25)
	 beatsTglOffset = beatsTglOffset + 28
	 table.insert(group_beatsToggles, tgl_beats[be])
	 beats[be] = 0
end

beatsTglOffset = frm_beats.x+74
for be = 9, 12 do
	 tgl_beats[be] = Toggle:Create(frm_beats.x + beatsTglOffset, frm_beats.y+82, be, htbeatsTgl, 20, 25)
	 beatsTglOffset = beatsTglOffset + 28
	 table.insert(group_beatsToggles, tgl_beats[be])
	 beats[be] = 0
end

beatsTglOffset = frm_beats.x+74

for be = 13, 16 do
	 tgl_beats[be] = Toggle:Create(frm_beats.x + beatsTglOffset, frm_beats.y+108, be, htbeatsTgl, 20, 25)
	 beatsTglOffset = beatsTglOffset + 28
	 table.insert(group_beatsToggles, tgl_beats[be])
	 beats[be] = 0
end


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


	-------------------------------
	--SELECT BUTTON----------------
	-------------------------------
	if btn_select.leftClick  or char == 13 then select_notes(true, false, sldr_minVel.value, sldr_maxVel.value, ib_minNote.value, ib_maxNote.value) end
	if btn_select.rightClick or gfx.mouse_cap == 8 and char == 13 then select_notes(true,true, sldr_minVel.value, sldr_maxVel.value, ib_minNote.value, ib_maxNote.value) end
	if btn_select.shiftLeftClick then
		select_notes(true, false, sldr_minVel.value, sldr_maxVel.value, ib_minNote.value, ib_maxNote.value)
		reaper.MIDIEditor_OnCommand(active_midi_editor, 40501)
	end
	if btn_select.ctrlLeftClick then
		select_notes(true, true, sldr_minVel.value, sldr_maxVel.value, ib_minNote.value, ib_maxNote.value)
	end

	-------------------------------
	--CLEAR BUTTON-----------------
	-------------------------------
	if btn_clear.leftClick or char == 08 then select_notes(true, false, -1, -1) end
	if btn_clear.rightClick or gfx.mouse_cap == 8 and char == 08 then
		select_notes(true, false, -1, -1)
		for e, element in ipairs(Elements) do
			element:Reset() 
			default_vars()
			update_pitch_toggles()
		end
	end

	-------------------------------
	--CAPTURE BUTTON---------------
	-------------------------------
	if btn_capture.leftClick then 
		set_from_selected(true, true, true, true, true, sldr_minVel, sldr_maxVel, ib_minNote, ib_maxNote) 
		update_pitch_toggles()
	end

	-------------------------------
	--NOTE RANGES------------------
	-------------------------------
	if ib_minNote.rightClick or ib_maxNote.rightClick then group_exec(group_noteRange, 'reset') end
	if ib_minNote.shiftLeftClick or ib_maxNote.shiftLeftClick then
		set_from_selected(true, true, false, false, false, nil, nil, ib_minNote, ib_maxNote) 
	end

	-------------------------------
	--PITCH Toggles----------------
	-------------------------------

	local count = 0
	for p, pp in ipairs(group_pitchToggles) do
		if pp.rightClick then group_exec(group_pitchToggles, 'reset') 
		elseif pp.leftClick then selectedNotes[p] = math.abs(selectedNotes[p] -1)
		elseif pp.ctrlLeftClick then 
			group_exec(group_pitchToggles, 'false')
			pp.state = true
		end
		if pp.shiftLeftClick then set_from_selected(false, false, false, false, true)
			update_pitch_toggles()
		end
		if pp.state then selectedNotes[p] = 1 else selectedNotes[p] = 0 end
		if pp.state == true then count = count + 1 end
	end

	if count == 0 then tgl_pitch[1].state = true ; selectedNotes[1] = 1 end

	-------------------------------
	--VEL Sliders------------------
	-------------------------------
	if sldr_minVel.rightClick or sldr_maxVel.rightClick then group_exec(group_velSliders, 'reset') end
	if sldr_minVel.shiftLeftClick or sldr_maxVel.shiftLeftClick then set_from_selected(false, false, true, true, false,  sldr_minVel, sldr_maxVel) end
	
	if sldr_minVel.value >= sldr_maxVel.value and hovering(sldr_minVel.x, sldr_minVel.y, sldr_minVel.w, sldr_minVel.h) then
		sldr_maxVel.value = sldr_minVel.value
	end
	if sldr_maxVel.value <= sldr_minVel.value and hovering(sldr_maxVel.x,sldr_maxVel.y,sldr_maxVel.w,sldr_maxVel.h) then
			sldr_minVel.value = sldr_maxVel.value
	end

	
	--Mutual Sliding
	
	if sldr_minVel.mouseDown == false then dif = sldr_maxVel.value - sldr_minVel.value end
	if sldr_minVel.ctrlLeftClick  then 
		if sldr_minVel.mouseDown then 
			if sldr_maxVel.value <=127 then
				sldr_minVel.override = true
				sldr_maxVel.value = sldr_minVel.value  + dif
			--else sldr_maxVel.value = 127
			end
		end
		
	else sldr_minVel.override = false 

	end

	if sldr_maxVel.mouseDown == false then dif2 = sldr_maxVel.value - sldr_minVel.value end
	if sldr_maxVel.ctrlLeftClick  then 
		if sldr_maxVel.mouseDown then 
			if sldr_minVel.value  >=0 then
				sldr_maxVel.override = true
				sldr_minVel.value = sldr_maxVel.value  - dif2
			--else sldr_minVel.value = 0
			end
		end
		
	else sldr_maxVel.override = false 

	end


	-------------------------------
	--BEAT Toggles----------------
	-------------------------------
	for p, pp in ipairs(group_beatsToggles) do
		if pp.rightClick then group_exec(group_beatsToggles, 'reset')
		elseif pp.leftClick then beats[p] = math.abs(beats[p] - 1) 
		end
	end


	if tgl_dockOnStart.leftClick then 
		if tgl_dockOnStart.state == true then 
			dockOnStart = "1"
			set_settings(reaper.GetResourcePath() .. '/Scripts/lemerchand/MIDI Selector Tool/lament.config', dockOnStart)
		else 
			dockOnStart = "0"
			set_settings(reaper.GetResourcePath() .. '/Scripts/lemerchand/MIDI Selector Tool/lament.config', dockOnStart)
		end

	end

end

main()
reaper.Undo_EndBlock(_name .. "", -1)

--------------------------------
--Special functions-------------
--------------------------------

function update_pitch_toggles()

	for p, pp in ipairs(tgl_pitch) do
		if selectedNotes[p] == 1 then pp.state = true else pp.state = false end
	end
end

