function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')

--Create window, add pin-to-top and get last focused window
gfx.init("Console", 400,300, false, 1400,400)
local win = reaper.JS_Window_Find("Console", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

--Counter for refreshing gui after resize
local refresh = 0

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



function main()

	fill_background()

	local char = gfx.getchar()
	if char == 27 or char == -1 then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else 
		-- Send characters to the textfields
		cmd:Change(char)
		-- if "/" then activate cmd
		if char == 47 and cmd.active == false then cmd.active = true end
		reaper.defer(main) 
	end


	--Draws all elements
	draw_elements()


	--If the cmd is click it's activated
	if cmd.leftClick then cmd.active = true end
	if cmd.active and cmd.txt == "s" then 

		-- for i=0, tracks-1 do
		-- 	local t = reaper.GetTrack(0, i )
		-- 	local retval, buf = reaper.GetTrackName( t )

		-- 	if buf == "Track 1" then cons(buf .. "\n") end
		-- end

		display.txt = "Select: " 

	end

	--If enter is pressed 
	if cmd.returned then 

		--Look for commands
		if cmd.txt == "hello" then display.txt = "HI!"
		else
			display.txt = "Nothing found..."
		end
		cmd.txt = ""
		cmd.returned = false
	end

	if refresh == 20 then 
		refresh = 0
		gui_size_update()
	else 
		refresh = refresh+1 
	end
	
end
main()