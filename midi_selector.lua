-------------------------------------------------------------------------------
--					MIDI Note Selection TOOL v.2
-------------------------------------------------------------------------------
--  Modified: 2020.10.13
--
--	TODO: 
--		+ Add the ability to select from: 
--					- Selected Notes 			- Capture Note (Note Range)
--					- Time Selection 			- Length

--		+ Reset per section 
--		+ Detector for beats---what if it's not perfectly on the grid?
-- 		+  Fix inclusive select for Notes
--
-- RECENT CHANGES:
-- 		+ Note number selection now works!
--		+ Make a value slider that fills from the right to the left
--		+ Add Note small_toggles()s
--		+ Selector for Hi/low note
--		+ Made UI element positions relative to the frames for easy adjustments
--		+ Created small_toggle() (tbu as a checkbox)
--
------------------------------------------------------------------------------

--Load UI Library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('cf.lua')

------------------------------
-- Global Variables --
------------------------------
function default_vars()

	test_toggle = 1									--For testing, lawl
	min_vel = 0
	max_vel = 127
	min_note = 'C6'									--Lowest Note to be acted upon
	max_note = 'D1'									--Highest note to be acted upon
	time_selection = 0								--Act on all notes or those in time selection
	beats = {0,0,0,0,0,0,0,0}						--Beat boolean, eg, 1st & 3rd, 6th and 8th
	notes_list = {1,1,1,1,1,1,1,1,1,1,1,1}			--C-G# Boolean
	note_midi_n = {0,1,2,3,4,5,6,7,8,9,10,11}		--Mini note numbers -- corresponds to note_names
													--uses modulus to determine note name regardless of range
	note_names = {'C','C#', 'D', 'D#', 'E',			--Note names for notes_list
				'F','F#', 'G', 'G#', 'A', 
				'A#','B'}


end
default_vars()



----------------------
--Window Mngmt--------
----------------------
--Get current midi window so it can refocus on it when script terminates

last_window = reaper.JS_Window_GetFocus()


--Open window at mouse position--
mousex, mousey = reaper.GetMousePosition()
gfx.init("MIDI Tool", 248, 630, false, mousex+50, mousey-125)
-- Keep on top
w = reaper.JS_Window_Find("MIDI Tool", true)
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
time_frame_x, time_frame_y, time_frame_w, time_frame_h = 10, vel_frame_y + vel_frame_h+frame_offset, 227, 65

----------------------
--MAIN PROGRAM--------
----------------------

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
	btn_exc_select = button(gen_frame_x + btn_offset_x, gen_frame_y+btn_offset_y,"   Select  ")
	btn_clear = button(gen_frame_x+btn_offset_x,gen_frame_y+52, "  Clear    ",2)
	if toggle(gen_frame_x+120,gen_frame_y+btn_offset_y,"Selection", time_selection) == 1 then time_selection = math.abs(time_selection  -1) end	
	btn_cut = button(gen_frame_x+120,gen_frame_y+52, "   Delete  ")

	--Pitch Frame
	frame(pitch_frame_x, pitch_frame_y, pitch_frame_w, pitch_frame_h)
	label(pitch_frame_x+2,pitch_frame_y-label_offset,"Pitch")
 
	text(pitch_frame_x+10, pitch_frame_y+13,"Low Note:")
	min_note = option_text(pitch_frame_x+75,pitch_frame_y+btn_offset_y, min_note, 1)
	text(pitch_frame_x+110, pitch_frame_y+13, "High Note:")
	max_note = option_text(pitch_frame_x+178,pitch_frame_y+btn_offset_y, max_note, 1)


	note_btn_pos = 0
	for i = 1,6 do
		if small_toggle(note_btn_pos + (i*31), pitch_frame_y+40, note_names[i], notes_list[i]) == 1 then notes_list[i] = math.abs(notes_list[i] - 1) end
	end
	beat_btn_pos = 0
	for i = 1,6 do
		if small_toggle(note_btn_pos + (i*31), pitch_frame_y+65, note_names[i+6], notes_list[i+6]) == 1 then notes_list[i+6] = math.abs(notes_list[i+6] - 1) end
	end	
	
	--Makes sure there is always at least one note selected
	c=0
	for b = 1, 12 do c = c + notes_list[b] end
	if c == 0 then notes_list[1] = 1 end
	




	--Velocity Frame
	frame(vel_frame_x, vel_frame_y, vel_frame_w, vel_frame_h)
	label(vel_frame_x+2,vel_frame_y-label_offset,"Velocity")
	min_vel = h_slider(vel_frame_x+35,vel_frame_y+btn_offset_y,"Min",min_vel, 0, 127)
	max_vel = h_slider(vel_frame_x+35,vel_frame_y+btn_offset_y+35,"Max",max_vel,0, 127, true)


	--Time Frame
	label(time_frame_x+2,time_frame_y-label_offset, "Beats")
	frame(time_frame_x,time_frame_y, time_frame_w, time_frame_h)

	beat_btn_pos = 0

	for i = 1,4 do
		if small_toggle(beat_btn_pos + (i*31), time_frame_y+btn_offset_y, i, beats[i]) == 1 then beats[i] = math.abs(beats[i] - 1) end
	end
	beat_btn_pos = 0
	for i = 1,4 do
		if small_toggle(beat_btn_pos + (i*31), time_frame_y+35, i+4, beats[i+4]) == 1 then beats[i+4] = math.abs(beats[i+4] - 1) end
	end	

	--------------------------
	--Deal with interactions--
	--------------------------

	if btn_exc_select == 1 then	select_notes(true, min_vel, max_vel)
	elseif btn_exc_select == 2 then	select_notes(false, min_vel, max_vel)
	elseif btn_clear == 1 then select_notes(true, -1, -1)
	elseif btn_clear == 2 then
		default_vars()
		select_notes(true, -1, -1)
	end

end

main()
