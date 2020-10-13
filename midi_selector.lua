--Load UI Library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('cf.lua')

------------------------------
-- Default Global Variables --
------------------------------
function var_init()

	min_vel = 0
	max_vel = 127
	min_note = 'C6'
	max_note = 'D1'
	time_selection = 0
	beats = {0,0,0,0,0,0,0,0}

end

var_init()


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


----------------------
--MAIN PROGRAM--------
----------------------

function main()

	fill_background()
	-- Get Kestrokes
	char = gfx.getchar()
	
	-- Deal with key stokes
	-- If char == ESC then close window`
	if char == 27 then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else reaper.defer(main) end


	----------------------
	--Create GUI----------
	----------------------
		
	--General Settings
	frame(10,28,227,90)
	l = label(12,8,"General")
	btn_exc_select = button(25,38,"   Select  ")
	btn_clear = button(25,80, "  Clear    ",2)
	if toggle(130,38,"Selection", time_selection) == 1 then time_selection = math.abs(time_selection  -1) end	
	btn_cut = button(130,80, "   Delete  ")

	--Pitch
	frame(10,150,227,40)
	label(12,130,"Pitch")
	--low_note = h_slider(20,160,"Min Vel",low_note, 0, 127)
	--hi_note = 
	text(20, 162,"Low Note:")
	min_note = option_text(85,160, min_note)
	text(125, 162, "High Note:")
	max_note = option_text(192,160, max_note)

	--Velocity
	frame(10,220,227,90)
	label(12,200,"Velocity")
	min_vel = h_slider(45,234,"Min Vel",min_vel, 0, 127)
	max_vel = h_slider(45,270,"Max Vel",max_vel,0, 127)


	--Time
	label(12,320, "Beats")
	frame(10,340, 227,88)

	beat_btn_pos = 0
	for i = 1,4 do
		if toggle(beat_btn_pos + (i*43), 350, i, beats[i]) == 1 then beats[i] = math.abs(beats[i] - 1) end
	end
	beat_btn_pos = 0
	for i = 1,4 do
		if toggle(beat_btn_pos + (i*43), 390, i+4, beats[i+4]) == 1 then beats[i+4] = math.abs(beats[i+4] - 1) end
	end


	--------------------------
	--Deal with interactions--
	--------------------------

	if btn_exc_select == 1 then	select_notes(true, min_vel, max_vel)
	elseif btn_exc_select == 2 then	select_notes(false, min_vel, max_vel)
	elseif btn_clear == 1 then select_notes(true, -1, -1)
	elseif btn_clear == 2 then
		select_notes(true, -1, -1)
		var_init()
	end

end

main()
