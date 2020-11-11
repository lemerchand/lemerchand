function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')

--Create window, add pin-to-top and get last focused window
gfx.init("Console", 400,300, false, 1400,400)
local win = reaper.JS_Window_Find("Console", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

--Counter for refreshing gui after resize
local refresh = 0

--Flag to prevent updating track selection when a command is entered
local engaged = false

--Table to hold selected tracks
local selectedTracks = {}

--Create and hide dummy status
status = Status:Create()
status.hide = true

--Create GUI frame and make everything relative to it
frame = Frame:Create(10, 0, gfx.w-20, gfx.h-30, "")

--Create the main text input field and set it to always active
local cmd = TextField:Create(10, frame.y+frame.h, frame.w+1, 20, "", "", true, false)
cmd.alwaysActive = true

--Create a text display for information
local display = Text:Create(20, 30, "", "", nil, nil, nil, nil, nil, false, frame.w-20)


--Handles resize whenever the refresh threshold is reached
local function gui_size_update()
	frame.w, frame.h = gfx.w-20, gfx.h-30
	cmd.w, cmd.y = frame.w+1, frame.y+frame.h

end

local function select_tracks(exclusive)
	update_active_arrange()
	display.txt = "Select...\n\n"
	for i=0, tracks-1 do
		local t = reaper.GetTrack(0, i )
		local retval, buf = reaper.GetTrackName( t )

		local input = cmd.txt:sub(3)
		local flags = cmd.txt:find("-")

		if flags then 
			flags = cmd.txt:sub(cmd.txt:find("-")-1)
			local input = cmd.txt:sub(3, cmd.txt:find("-"))
		else
			local input = cmd.txt:sub(3)
		end
		
		cons(tostring(flags), true)
	

		if string.lower(buf):match(input) then reaper.SetTrackSelected( t, true ) 
			display.txt = display.txt .. buf .. "\n"
		else 
			reaper.SetTrackSelected( t, false) 
		end
	end
end

local function update_selected_tracks()
	update_active_arrange()
	for i = 0, tracks - 1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) then selectedTracks[i] = true
		else
			selectedTracks[i] = false
		end
	end
end

local function restore_selected_tracks()

	for i = 0, tracks-1 do
		reaper.SetTrackSelected(reaper.GetTrack(0, i), selectedTracks[i])
	end
end

local function mute_selected_tracks()
	for i = 0, tracks-1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) then 
			reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), 'B_MUTE', 1 )
		end
	end
end


local function update_cmd(char)

	if not engaged and cmd.txt ~= "" then 
		update_selected_tracks()
		engaged = true
	end

	--------------------------
	--While Typing Updates----
	--------------------------
	if cmd.active and cmd.txt:sub(1,1) == "s" then 
		select_tracks(false)
	elseif cmd.active and cmd.txt:sub(1,1) == "S" then
		select_tracks(true)
	end

	--------------------------
	--Text field handling-----
	--------------------------

	--If enter is pressed 
	if cmd.returned then 

		--Look for commands
		if cmd.txt == "hello" then display.txt = "HI!"
		elseif cmd.txt:find("-m") then mute_selected_tracks()
		else
			
			display.txt = "Nothing found..."
		end
		cmd.txt = ""
		cmd.returned = false
		update_selected_tracks()
		engaged = false
	end

end

function main()

	--Draws all elements
	fill_background()
	draw_elements()
	
	local char = gfx.getchar()
	if char == 27 or char == -1 then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else 

		-- if "/" then activate cmd
		if char == 47 and cmd.active == false then cmd.active = true 
		-- if ctrl+backspace or the user clears out the cmd then clear text and restore the selected tracks
		elseif (char == 8 and gfx.mouse_cap == 04) or (engaged and cmd.txt == "" ) then 
			cmd.txt = ""
			restore_selected_tracks()
			engaged = false
		else
			-- Send characters to the textfields
			cmd:Change(char)
			update_cmd(char)
		end
		reaper.defer(main) 
	end





	--If the cmd is click it's activated
	if cmd.leftClick then cmd.active = true end



	--Refresh the gui size 
	if refresh == 20 then 
		refresh = 0
		gui_size_update()
	else 
		refresh = refresh+1 
	end
	
end
main()