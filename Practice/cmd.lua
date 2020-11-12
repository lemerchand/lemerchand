function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')
reaper.ClearConsole()

--Create window, add pin-to-top and get last focused window
gfx.init("Console", 400,300, false, 1400,400)
local win = reaper.JS_Window_Find("Console", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

--Counter for refreshing gui after resize
local refresh = 0

--Common properties for the comman line
local c = {engaged = false, exitOnCommand = false, flags="", recall = 0, prev=1, cmd = {}}
c.cmd[1] = ""

--Table to hold selected tracks
local prevSelectedTracks = {}
local curSelectedTracks = {}

--Create and hide dummy status
status = Status:Create()
status.hide = true

--Create GUI frame and make everything relative to it
frame = Frame:Create(10, 0, gfx.w-20, gfx.h-30, "")

--Create the main text input field and set it to always active
local cmd = TextField:Create(10, frame.y+frame.h, frame.w+1, 20, "", "", true, false)
cmd.alwaysActive = true

--Create a text display for information
local display = Text:Create(20, 30, "", "", nil, nil, nil, nil, nil, false, frame.w/3)
local display2 = Text:Create(display.x+display.w+20, 30, "", "", nil, nil, nil, nil, nil, false, frame.w/3)
local display3 = Text:Create(display2.x+display2.w-20, 30, "", "", nil, nil, nil, nil, nil, false, frame.w/3)
local displays = {display, display2, display3}

--Handles resize whenever the refresh threshold is reached
local function gui_size_update()
	frame.w, frame.h = gfx.w-20, gfx.h-30
	cmd.w, cmd.y = frame.w+1, frame.y+frame.h
end

--Loads given table with currently selected tracks
local function update_selected_tracks(selectedTracks)
	update_active_arrange()
	for i = 0, tracks - 1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) then selectedTracks[i] = true
		else
			selectedTracks[i] = false
		end
	end
end

--Selects tracks by name
local function select_tracks(exclusive)
	update_active_arrange()
	
	--reset the displays
	display.txt = "Selected:\n\n"
	display2.txt = "\n\n"
	display3.txt = "\n\n"

	--Helps formats display with excessive track count
	local displaySpacer = 0

	--Trim command from user input
	local input = cmd.txt:sub(3)

	--look for and extract flags
	--If a flag is found then trim input to just before flag
	if cmd.txt:find("=") then 
		local s, e = cmd.txt:find("=")
		c.flags = cmd.txt:sub(s+1)
		input = cmd.txt:sub(3, cmd.txt:find("=")-1)
	end
		

	for i=0, tracks-1 do
		local t = reaper.GetTrack(0, i )
		local retval, buf = reaper.GetTrackName( t )
	
		--if the string is an exact match	
		if string.lower(buf) == input or string.lower(buf .. " ") == input or string.lower(buf .. "  ") == input then 
			reaper.SetTrackSelected( t, true ) 
			displaySpacer = displaySpacer + 1

			--Format and display selected tracks
			if displaySpacer > 32 then
				display3.txt = display3.txt .. buf:sub(1,16) .. "\n"
			elseif displaySpacer > 16 then
				display2.txt = display2.txt .. buf:sub(1,16) .. "\n"
			else
				display.txt = display.txt .. buf:sub(1,16) .. "\n"
			end
		else 

			--finds close matches
			if string.lower(buf):match(input) and string.lower(buf .. " ") ~= input then 
				reaper.SetTrackSelected( t, true ) 
				displaySpacer = displaySpacer + 1

				--Format and display selected tracks
				if displaySpacer > 32 then
					display3.txt = display3.txt .. buf:sub(1,16) .. "\n"
				elseif displaySpacer > 16 then
					display2.txt = display2.txt .. buf:sub(1,16) .. "\n"
				else
					display.txt = display.txt .. buf:sub(1,16) .. "\n"
				end
			--if i is not a match deselect
			else 
				reaper.SetTrackSelected( t, false) 
		end
	end
	
end
	
	
end

--Restores the selection if user cancels command
local function restore_selected_tracks()
	for i = 0, tracks-1 do
		reaper.SetTrackSelected(reaper.GetTrack(0, i), prevSelectedTracks[i])
	end
end

--Sets selected tracks param with state 
local function set_selected_tracks(param, state, exclusive)
	for i = 0, tracks-1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) then 
			if state == -1 then
				reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, i), param, math.abs(reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), param)-1))
			else
				reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), param, state)
			end
		end

		--if exclusive mode then fuck this track in it's asshole
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) == false and exclusive then 
			reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), param, 0)
		end
	end
end

--Update the cmd prompt
--Should help CPU by only doing checks when characters change
local function update_cmd(char)

	--c.engaged means we can stop looking for commands
	--so in this case, if we aren't engaged and the prompt is "" then the user
	--cleared the prompt and we can restore the track selection from before they began typing
	if not c.engaged and cmd.txt ~= "" then 
		update_selected_tracks(prevSelectedTracks)
		c.engaged = true
	end

	----------------------------
	--While typing -------------
	----------------------------
	--Look for various prefix commands
	if cmd.active and cmd.txt:sub(1,1) == "s" then 
		select_tracks(false)
	elseif cmd.active and cmd.txt:sub(1,1) == "S" then
		select_tracks(true)
	end


	-------------------------------
	--Committed Input Handling-----
	-------------------------------
	if cmd.returned then 

		reaper.Undo_BeginBlock()

		--Adds the committed input to the history
		c.prev = c.prev + 1
		c.cmd[c.prev] = cmd.txt


		--If the commit is "hello"
		if cmd.txt == "hello" then display.txt = "HI!" end

		--Look for mute 
		if c.flags:find("m%-") then set_selected_tracks('B_MUTE', 0, false)
		elseif c.flags:find("m%+") then set_selected_tracks('B_MUTE', 1, false)
		elseif c.flags:find("m") then set_selected_tracks('B_MUTE',-1, false)
		elseif c.flags:find("M") then set_selected_tracks('B_MUTE',1, true)
		end

		--Look for solo
		if c.flags:find("o%-") then set_selected_tracks("I_SOLO", 0, false)
		elseif c.flags:find("o%+") then set_selected_tracks('I_SOLO', 1, false)
		elseif c.flags:find("o") then set_selected_tracks('I_SOLO',-1, false)
		elseif c.flags:find("O") then set_selected_tracks('I_SOLO', 1, true)
		end

		--Look for arm
		if c.flags:find("a%-") then set_selected_tracks("I_RECARM", 0, false)
		elseif c.flags:find("a%+") then set_selected_tracks('I_RECARM', 1, false)
		elseif c.flags:find("a") then set_selected_tracks('I_RECARM',-1, false)
		elseif c.flags:find("A") then set_selected_tracks('I_RECARM', 1, true)
		end

		--Look for fx bypas
		if c.flags:find("b%-") then set_selected_tracks("I_FXEN", 0, false)
		elseif c.flags:find("b%+") then set_selected_tracks('I_FXEN', 1, false)
		elseif c.flags:find("b") then set_selected_tracks('I_FXEN',-1, false)
		end


		--Clear cmd, clear engage, clear returned, clear flags
		--commit the currently selected tracks to previous selected tracks
		--reset recall 

		cmd.txt = ""
		cmd.returned = false
		update_selected_tracks(prevSelectedTracks)
		c.engaged = false
		c.flags = ""
		c.recall = count_table(c.cmd)+1


	end

end

function main()

	--Draws all elements
	fill_background()
	draw_elements()
	
	local char = gfx.getchar()
	if char == 27 or char == -1  or c.exitOnCommand then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else 

		-- if "/" then activate cmd
		if char == 47 and cmd.active == false then cmd.active = true 
		--Undo/redo
		elseif char == 26 and gfx.mouse_cap == 12 then reaper.Main_OnCommand(40030, 0)
		elseif char == 26 then reaper.Main_OnCommand(40029, 0)

		-- if ctrl+backspace or the user clears out the cmd then clear text and restore the selected tracks
		elseif (char == 8 and gfx.mouse_cap == 04) or (c.engaged and cmd.txt == "" ) then 
			cmd.txt = ""
			for d, dd in ipairs(displays) do dd.txt="" end
			restore_selected_tracks()
			c.engaged = false
	
		--if up arrow
		elseif char == 30064 then 
			if c.recall - 1 == 1 then 
				c.recall = 2 
				cmd.txt = c.cmd[c.recall]
			else 
				c.recall = c.recall - 1
				cmd.txt = c.cmd[c.recall]
			end
			
		--if down arrow	
		elseif char == 1685026670 then

			if c.recall + 1 > count_table(c.cmd) then 
				c.recall = count_table(c.cmd)
				cmd.txt = c.cmd[1]
			else
				c.recall = c.recall + 1 
				cmd.txt = c.cmd[c.recall]
			end
			
		else --user is typing
			--if the user presses ctrl+enter then exit after commit
			if gfx.mouse_cap == 04 and char == 13 then c.exitOnCommand = true end

			-- Send characters to the textfields
			cmd:Change(char)
			update_cmd(char)

			--if the user isn't scrolling through the history then set c.cmd[1]
			if c.recall == count_table(c.cmd)+1 then c.cmd[1] = cmd.txt end
		end
		reaper.defer(main) 
	end



	--If the cmd is click it's activated
	if cmd.leftClick then cmd.active = true end

	--Refresh the gui size 
	if refresh == 75 then 
		refresh = 0
		gui_size_update()
	else 
		refresh = refresh+1 
	end
	
end
main()
reaper.Undo_EndBlock("Something wicked", -1)