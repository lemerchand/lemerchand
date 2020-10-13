mousex, mousey = reaper.GetMousePosition()
gfx.init("MIDI Tool", 250, 250, false, mousex-125, mousey-125)

test_values = {0,1,2,3,4,5,6}
current_value = 0
t = 0
t2 = 600000

local function time_check(a,b)
	
	gfx.drawstr(a)
	if a+b < reaper.time_precise() then return true
	else return false
	end

end

local function btn_test()
	gfx.x, gfx.y = 15, 175
	item = reaper.GetSelectedMediaItem(0, 0)
	take = reaper.GetActiveTake(item)
	gfx.drawstr("Total Notes: " .. reaper.MIDI_CountEvts(take))
end

local function select(beat1, beat2)
	item = reaper.GetSelectedMediaItem(0, 0)
	take = reaper.GetActiveTake(item)
	notes = reaper.MIDI_CountEvts(take)


	for i = 0, notes -1 do
		 retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
		 if startppqpos == beat1 or startppqpos == beat2 then
		 	reaper.MIDI_SetNote(take, i, 1, 0, -1, -1, 1, -1, vel+20, True)
		 else
		 	reaper.MIDI_SetNote(take, i, 0, 0, -1, -1, 1, -1, -1, True)
		 end
	reaper.MIDI_Sort(take)
	end
end

local function value_slider(x,y,text, values)
	gfx.x, gfx.y = x,y
	
	--gfx.drawstr("Values: " .. time_check)
	gfx.drawstr("Current Value: " .. current_value+1)
	if gfx.mouse_y >= y and gfx.mouse_y <= y+15 and gfx.mouse_wheel > 0 then
		if (current_value + 1) >= #values then
			if time_check(t, t2) then current_value = values[1] end
			t = reaper.time_precise()
		else
			if time_check(t,t2) then current_value = current_value + 1 end
			t = reaper.time_precise()
		end
	elseif gfx.mouse_y >= y and gfx.mouse_y <= y+15 and gfx.mouse_wheel < 0 then
		if (current_value - 1) <= 0  then
			if time_check(t,t2) then current_value = #values end
			t = reaper.time_precise()
		else
			if time_check(t,t2) then current_value = current_value - 1 end
			t = reaper.time_precise()
		end
	end

	gfx.mouse_wheel = 0
end

local function button(x,y,text)
	-- Creates a button at x and y with text.
	-- Returns 1 if left mouse clicks within the button and 0 if not
	-- Convert text length into pixels
	local button_width, button_height = gfx.measurestr(text)
	
	-- Create button graphic
	gfx.set(.2,.2,.2,1)
	gfx.rect(x,y, button_width+29, 30)
	gfx.r, gfx.g, gfx.b = .4, .4, .4
	gfx.rect(x+1,y+1, button_width+29, 30, false)

	-- Set text
	gfx.setfont(1, arial,20)
	gfx.x, gfx.y = x+15,y+7
	gfx.drawstr(text, 1)

	-- Detect left mouse click
	if gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30 and  gfx.mouse_cap == 1 then
		return 1
	else
		return 0
	end
end


function main()
	-- Get Kestrokes
	char = gfx.getchar()
	-- If char == ESC then close window`
	if char == 27 then
		return 0
	-- Otherwise keep window open
	else
		reaper.defer(main)
	end

	-- Declare buttons
	t = button(15,55,"Count Notes")
	t2 = button(15,15,"Select 1 and 3")
	t3 = button(15,95,"Select 2 and 4")
	
	value_slider(15,200, "Current Value:", test_values, current_value)	


	-- Check to see if button was pressed
	if t == 1 then
		btn_test()
	elseif t2 == 1 then 
		select(0,1920)
	elseif t3 == 1 then
		select(960,2880)
	-- If no button was pressed...
	else
		-- If needed
	end	

	w = reaper.JS_Window_Find("MIDI Tool", true)
	if w then reaper.JS_Window_AttachTopmostPin(w) end

end
t= reaper.time_precise()
main()
