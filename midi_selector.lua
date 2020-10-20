-------------------------------------------------------------------------------
--					MIDI Selection TOOL 3k v.9b
-------------------------------------------------------------------------------
--  Modified: 2020.10.20 at 5am
--
--	TODO: 
-- 		+ 
-- 		+ Length
-- 		+ Fix inclusive select for Notes
-- 		+ Scales?
-- 		+ Make Beat presets persistant by saving to and reading from a file
-- 		+ Inverted select 
--
-- RECENT CHANGES:
--		+ Set parameters from selection
-- 		+ Time selection toggle
--		+ Helptext on mousehover
--		+ Beat selector works and detects selected beat up to +/- 30 ppq--
--
--- KNOWN ISSUES:
--		+ Bad values for pitch range aren't checked for
--		+ Inclusive select don't b wurk
------------------------------------------------------------------------------
_version = .95


--Load UI Library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('cf.lua')

------------------------------
-- Global Variables --
------------------------------
note_midi_n = {0,1,2,3,4,5,6,7,8,9,10,11}			--Covers all 12 notes (pitch%12)
note_names = {'C','C#', 'D', 'D#', 'E',				--Note names for notes_list
			'F','F#', 'G', 'G#', 'A', 
			'A#','B'}


--Patterns for beats
beats_a1 = 				{1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0}
beats_a2 =				{0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0}
beats_b2 =				{0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0}
beats_b1 = 				{1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0}
beats_c1 =				{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
beats_c2 =				{0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1}

--PPQ values for 16th notes
beats_in_ppq = {0,240,480,720,960,1200,1440,1680,1920,2160,2400,2640,2880,3120,3360,3600}



beats_as_ppq = {}

function default_vel()
	min_vel = 0
	max_vel = 127
end

function default_note_range()
	min_note = 'C0'									--Lowest Note to be acted upon
	max_note = 'G10'								--Highest note to be acted upon
end
						
function default_beats()
	beats = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}		--Beat boolean, eg, 1st & 3rd, 6th and 8th
end

function default_pitch()
	notes_list = {1,1,1,1,1,1,1,1,1,1,1,1}			--C-G# Boolean
end

												
function default_vars()
	default_vel()
	default_note_range()
	default_beats()
	default_pitch()
end

function clear_pitch()
	notes_list = {0,0,0,0,0,0,0,0,0,0,0,0}
end
default_vars()

----------------------------------------------------------
--Help Text----------Line break before end of this heading
----------------------------------------------------------
ht_select =				"Select notes based on settings.\nR-click restricts to time selection.\nShift+L-click to invert filter."
ht_clear = 				"Clear Selection. \nR-click for global reset.\nHotkeys: (Shift+) Backspace"
ht_capture = 			'Set parameters from selected notes.\nOr Shift+L-Click a parameter.'
ht_range_low = 			"Set minimum velocity.\nR-click to reset."
ht_range_hi = 			"Set maximum velocity.\nR-click to reset."
ht_pitch_select = 		"Toggles pitches.\nR-click to reset.\nCtrl+L-click: exclusive select."
ht_min_vel =  			"Sets the lowest selectable pitch.\nR-click to reset."
ht_max_vel =			"Set the highest selectable pitch.\nR-click to reset."
ht_beat_select = 		"Include/exclude specific beats.\nR-click to reset.\nCtrl+L-click: exclusive select."
ht_btn_beats =			"Recalls beat patterns.\nR-click for an additional preset."
ht_delete =				"Unused"


----------------------
--Window Mngmt--------
----------------------
--Get current midi window so it can refocus on it when script terminates

last_window = reaper.JS_Window_GetFocus()


--Open window at mouse position--
mousex, mousey = reaper.GetMousePosition()
gfx.init("MST3k v " .. _version, 248, 630, false, mousex+150, mousey-125)
-- Keep on top
w = reaper.JS_Window_Find("MST3k v " .. _version, true)
if w then reaper.JS_Window_AttachTopmostPin(w) end


--Frame Properties for quicker GUI adjustment
--Each frame = the height and y position of the previous frame
--I left the other options here even though they aren't modified in case I want to orient them differently
frame_offset = 31
label_offset = 20
btn_offset_x = 15
btn_offset_y = 10
gen_frame_x, gen_frame_y, gen_frame_w, gen_frame_h = 10, 28, 227, 90
pitch_frame_x, pitch_frame_y, pitch_frame_w, pitch_frame_h = 10, gen_frame_y + gen_frame_h + frame_offset, 227, 100
vel_frame_x, vel_frame_y, vel_frame_w, vel_frame_h = 10, pitch_frame_y + pitch_frame_h+frame_offset, 227 , 85
time_frame_x, time_frame_y, time_frame_w, time_frame_h = 10, vel_frame_y + vel_frame_h+frame_offset, 227, 115
info_frame_x, info_frame_y, info_frame_w, info_frame_h = 10, time_frame_y + time_frame_h+frame_offset, 227,60


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
	if char == 27 or char == -1 or char == 116 then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else reaper.defer(main) end


	----------------------
	--Create GUI----------
	----------------------

	--General Frame


	frame(gen_frame_x, gen_frame_y, gen_frame_w, gen_frame_h)
	label(gen_frame_x+2,gen_frame_y-label_offset,"General")
	btn_select = button(gen_frame_x + btn_offset_x, gen_frame_y+btn_offset_y,"   Select  ",-1, ht_select)
	btn_clear = button(gen_frame_x+btn_offset_x,gen_frame_y+52, "   Clear   ",2,ht_clear)
	btn_capture =button(gen_frame_x+120,gen_frame_y+btn_offset_y," Capture ", 0, ht_capture)
	btn_cut = button(gen_frame_x+120,gen_frame_y+52, "  Unused ",0, ht_delete)

	--Pitch Frame
	frame(pitch_frame_x, pitch_frame_y, pitch_frame_w, pitch_frame_h)
	label(pitch_frame_x+2,pitch_frame_y-label_offset,"Pitch")
 

	--make sure there is a correct low/max note
	if min_note == 2 or max_note == 2 then default_note_range() 
	elseif min_note == 9 then set_from_selected(true, false, false, false) 
	elseif max_note == 9 then 
		set_from_selected(false, true, false, false)
	end



	text(pitch_frame_x+10, pitch_frame_y+13,"Low Note:")
	min_note = option_text(pitch_frame_x+75,pitch_frame_y+btn_offset_y, min_note, ht_range_low)
	text(pitch_frame_x+110, pitch_frame_y+13, "High Note:")
	max_note = option_text(pitch_frame_x+178,pitch_frame_y+btn_offset_y, max_note, ht_range_hi)


	note_btn_pos = 0
	for i = 1,6 do
		btn = small_toggle(note_btn_pos + (i*31), pitch_frame_y+40, note_names[i], notes_list[i], ht_pitch_select)
		if btn == 1 then notes_list[i] = math.abs(notes_list[i] - 1) 
		elseif btn == 2 then default_pitch()
		elseif btn == 5 then 
			clear_pitch()
			notes_list[i] = 1
		elseif btn == 9 then
			set_from_selected(false,false,false,false,true)
		end
	end
	beat_btn_pos = 0
	for i = 1,6 do
		btn= small_toggle(note_btn_pos + (i*31), pitch_frame_y+65, note_names[i+6], notes_list[i+6], ht_pitch_select)
		if btn == 1 then notes_list[i+6] = math.abs(notes_list[i+6] - 1)
		elseif btn ==2 then default_pitch()
		elseif btn == 5 then 
			clear_pitch()
			notes_list[i+6] = 1
		elseif btn == 9 then
			set_from_selected(false,false,false,false,true)
	 	end
	end	
	
	--Makes sure there is always at least one note selected
	c=0
	for b = 1, 12 do c = c + notes_list[b] end
	if c == 0 then notes_list[1] = 1 end
	

	--Velocity Frame
	frame(vel_frame_x, vel_frame_y, vel_frame_w, vel_frame_h)
	label(vel_frame_x+2,vel_frame_y-label_offset,"Velocity")

	min_vel = h_slider(vel_frame_x+35,vel_frame_y+btn_offset_y,"Min",min_vel, 0, 127, false, ht_range_low)
	max_vel = h_slider(vel_frame_x+35,vel_frame_y+btn_offset_y+35,"Max",max_vel,0, 127, true,ht_range_hi)
	if min_vel == -2222 or max_vel == -2222 then default_vel()
	elseif min_vel == -9999 then set_from_selected(false, false, true, false)
	elseif max_vel == -9999 then set_from_selected(false, false, false, true)
	end
	if min_vel >= max_vel  then max_vel = min_vel end



	--Time Frame
	label(time_frame_x+2,time_frame_y-label_offset, "Beats")
	frame(time_frame_x,time_frame_y, time_frame_w, time_frame_h)


	------------------Beat buttons
	beat_btn_pos = 70

	for i = 1,4 do
		btn = small_toggle(beat_btn_pos + (i*31), time_frame_y+btn_offset_y, i, beats[i], ht_beat_select) 
		if btn == 1 then beats[i] = math.abs(beats[i] - 1) 
		elseif btn == 2 then default_beats()
		elseif btn == 5 then 
			default_beats()
			beats[i] = 1
		end

	end

	beat_btn_pos = 70
	for i = 1,4 do
		btn = small_toggle(beat_btn_pos + (i*31), time_frame_y+35, i+4, beats[i+4], ht_beat_select)
		if btn == 1 then beats[i+4] = math.abs(beats[i+4] - 1)
		elseif btn == 2 then default_beats()
		elseif btn == 5 then 
			default_beats()
			beats[i+4] = 1
		end
	end	

	beat_btn_pos = 70

	for i = 1,4 do
		btn = small_toggle(beat_btn_pos + (i*31), time_frame_y+60, i+8, beats[i+8], ht_beat_select) 
		if btn == 1 then beats[i+8] = math.abs(beats[i+8] - 1) 
		elseif btn == 2 then default_beats()
		elseif btn == 5 then 
			default_beats()
			beats[i+8] = 1
		end
	end

	beat_btn_pos = 70
	for i = 1,4 do
		btn = small_toggle(beat_btn_pos + (i*31), time_frame_y+85, i+12, beats[i+12], ht_beat_select)
		if btn == 1 then beats[i+12] = math.abs(beats[i+12] - 1)
		elseif btn == 2 then default_beats()
		elseif btn == 5 then 
			default_beats()
			beats[i+12] = 1
		end
	end	

	--Beat Pattern Buttons

	btn_beats_a = button(time_frame_x+btn_offset_x,time_frame_y+btn_offset_y+1,"A",0,ht_btn_beats)
	btn_beats_b = button(time_frame_x+btn_offset_x,time_frame_y+44,"B",1,ht_btn_beats)
	btn_beats_c = button(time_frame_x+btn_offset_x,time_frame_y+77,"C",0,ht_btn_beats)


	--Info Frame
	label(info_frame_x+2, info_frame_y-label_offset, "Info")
	frame(info_frame_x, info_frame_y, info_frame_w, info_frame_h)
	


	--------------------------
	--Deal with interactions--
	--------------------------

	if btn_select == 2 or gfx.mouse_cap == 8 and char == 13 then select_notes(true, min_vel, max_vel, true)
	elseif btn_select == 9 then 
		select_notes(true, min_vel, max_vel, false)
		reaper.MIDIEditor_OnCommand(active_midi_editor, 40501)
	elseif btn_select == 1 or char == 13 then select_notes(true, min_vel, max_vel, false)
	elseif btn_clear == 2 or gfx.mouse_cap == 8 and char == 08 then
		default_vars()
		select_notes(true, -1, -1, false)
	elseif btn_clear == 1 or char == 08 then select_notes(true, -1,-1, false)
	elseif btn_capture == 1 then set_from_selected(true, true, true, true, true)
	elseif btn_beats_a == 1 then 
		beats = beats_a1
	elseif btn_beats_a == 2 then
		beats = beats_a2 
	elseif btn_beats_b == 1 then 
		beats = beats_b1
	elseif btn_beats_b == 2 then
		beats = beats_b2
	elseif btn_beats_c == 1 then 
		beats = beats_c1
	elseif btn_beats_c == 2 then
		beats = beats_c2
	 

	end

	-----------------------------
	--For Debugging
	-----------------------------
	-- update_active()
	--cons("Mouse_cap: " .. gfx.mouse_cap,true)







end

main()
reaper.Undo_EndBlock("Selected notes via MIDI Selector Tool", -1)