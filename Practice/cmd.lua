-- @version 0.6.6b
-- @author Lemerchand
-- @provides
--     [main] .
--     [nomain] /libss/*.lua
-- @changelog
--     + Logged commands persist on close
--     + Enabled routing of midi and audio
--     + Added help pages

function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../libss/gui.lua')
reaperDoFile('../libss/cf.lua')
reaper.ClearConsole()

--Create window, add pin-to-top and get last focused window

local mousex, mousey = reaper.GetMousePosition()

gfx.init("ReaCon", 425, 310, false, mousex+50,mousey-200)
local win = reaper.JS_Window_Find("ReaCon", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end


----------------------------
--Custom Colors-------------
----------------------------

local default = {r=.7, g=.7, b=.7}
local white = {r=.8, g=.8, b=.8}
local red = {r=.7, g=.1, b=.2}
local green = {r=.2, g=.65, b=.11}
local blue = {r=.25, g=.5, b=.9}
local grey = {r=.41, g=.4, b=.37}
local yellow = {r=.75, g=.7, b=.3}
local something = {r=.65, g=.25, b=.35}


-------------------------------
--Variables and whatnot--------
-------------------------------

--Counter for refreshing gui after resize
local refresh = 0
local helppage = 0

--Common properties for the comman line


--Table to hold selected tracks
local prevSelectedTracks = {}
local curSelectedTracks = {}
local sources = {}


-------------------------------
--GUI Init---------------------
--------------------------------

--Create and hide dummy status
status = Status:Create()
status.hide = true

--Create GUI frame and make everything relative to it
frame = Frame:Create(10, -5, gfx.w-20, gfx.h, "")

--Create the main text input field and set it to always active
local cmd = TextField:Create(10, frame.y+frame.h, frame.w+1, 20, "", "", true, false)
cmd.alwaysActive = true

--Create a text display for information
local display = Display:Create(frame.x+15, frame.y+20, frame.w-135, frame.h-60)
local display2 = Display:Create(frame.x+15, frame.y+frame.h-40, frame.w-120, frame.h)




------------------------------
--CMD Prompt Class-------------
------------------------------
CMD = {}
CMD.__index = CMD

function CMD:Create()
	local this = {
		engaged = false,
		exitOnCommand = false,
		txt = "",
		prefix = "",
		suffix = "",
		targets = {},
		trackNumbers = {},
		destinationInput = "",
		destination = "",
		destinationNumber = nil,
		desitinationSuffix = "",
		destinationID = nil,
		history = {},
		historySeek = 0,
		renaming=nil,
		exclusive = false,

	}
	setmetatable(this, CMD)
	return this
end

function CMD:PrevCMD()
	if self.historySeek == 0 then
	elseif self.historySeek - 1 == 0 then 
		self.historySeek = 1
		cmd.txt = self.history[self.historySeek] 
	elseif self.historySeek == 0 then
		cmd.txt = ""
		C.historySeek = count_table(C.history)+1
	else 
		self.historySeek = self.historySeek - 1
		cmd.txt = self.history[self.historySeek]
	end

	cmd.cpos = string.len(cmd.txt)

end

function CMD:NextCMD()

	if self.historySeek + 1 > count_table(self.history) then 
		self.historySeek = count_table(self.history)
		cmd.txt = ""
	else
		self.historySeek = self.historySeek + 1 
		cmd.txt = self.history[self.historySeek]
	end
	cmd.cpos = string.len(cmd.txt)
end

function CMD:Reset()
	self.historySeek = count_table(self.history)+1
	self.txt = ""
	self.prefix = ""
	self.suffix = ""
	--self.exitOnCommand = false
	self.engaged = false
	self.targets = {}
	self.renaming = nil
	self.trackNumbers = {}
	self.exclusive = false
	self.destinationInput = ""
	self.destination = ""
	self.destinationSuffix = ""
	self.destinationID = nil
end

function CMD:Parse()

	self.txt = cmd.txt
	self.prefix = cmd.txt:sub(1,1)
	local trackNumber = nil

	--Trim command from user input
	local input = cmd.txt:sub(3)
	local destinationInput = ""
	self.targets = {}
	self.trackNumbers = {}
	self.renaming = nil
	

	--YOOOOWZA
	-- If the routing symbol is found, it must be process separately from the rest of the commnand
	-- Strip it from the main input var and give it over to destinationInput

	if input:find(">") then 
		destinationInput = input:sub(input:find(">")+1)
		input = input:sub(1, input:find(">")-1)
	elseif input:find("<") then 
		destinationInput = input:sub(input:find("<")+1)
		input = input:sub(1, input:find("<")-1)
	end
	if destinationInput:find("=") then 
		local s, e = destinationInput:find('=')
		self.destinationSuffix = destinationInput:sub(s+1)
		destinationInput = string.lower(destinationInput:sub(1, destinationInput:find("=")-1))
	end

	if destinationInput:sub(1,1) == (" ") then destinationInput = destinationInput:sub(2) end
	self.destinationInput = string.lower(destinationInput)
		

		--Look for quotes for naming 
	if input:find('".*"') then 
		local s, e = input:find('".*"')
		self.renaming = input:sub(s+1, e-1)
		input = input:gsub('".*"', '')
	end

	if input:find("=") then 
		local s, e = input:find('=')
		self.suffix = input:sub(s+1)
		input = input:sub(1, input:find("=")-1)
	end


	for n in input:gmatch("#%d+") do
		if n ~= nil then trackNumber = tonumber(n:sub(2)) end
		table.insert(self.trackNumbers, trackNumber)
	end
	input = input:gsub("#%d+*", "")


	if input:sub(string.len(input)-1):match("%s+") then 
		input = input:sub(1,-1) 
	end
	input = input .. ","
	
	for t in input:gmatch('[%a%s%d!@#-]*,') do
		local tt = t:gsub(",", "")
		table.insert(self.targets, tt)
	end

end


local C = CMD:Create()

function display2:CommitPreview(trackCount, sources)

	local selectedSources = 0
	if sources then 
		for i = 0, #sources do
			if sources[i] == true then selectedSources = selectedSources + 1 end
		end
	end

	--Look for flags to add to commit preview
	local commitPreview = ""
	if C.suffix:find("m%-") then commitPreview = commitPreview .. "Unmute, "
	elseif C.suffix:find("m%+") then commitPreview = commitPreview .. "Mute, "
	elseif C.suffix:find("m") then commitPreview = commitPreview .. "Toggle Mute, "
	elseif C.suffix:find("M") then commitPreview = commitPreview .. "Excl. Mute, "
	end

	--Look for solo
	if C.suffix:find("o%-") then commitPreview = commitPreview .. "Unsolo, "
	elseif C.suffix:find("o%+") then commitPreview = commitPreview .."Solo, "
	elseif C.suffix:find("o") then commitPreview = commitPreview .. "Toggle Solo, "
	elseif C.suffix:find("O") then commitPreview = commitPreview .. "Excl. Solo, "
	end

	--Look for arm
	if C.suffix:find("a%-") then commitPreview = commitPreview .. "Unarm, "
	elseif C.suffix:find("a%+") then commitPreview = commitPreview .."Arm, "
	elseif C.suffix:find("a") then commitPreview = commitPreview .. "Toggle Arm, "
	elseif C.suffix:find("A") then commitPreview = commitPreview .. "Excl. Arm, "
	end

	--Look for fx bypass
	if C.suffix:find("b%-") then commitPreview = commitPreview .. "Bypass FX, "
	elseif C.suffix:find("b%+") then commitPreview = commitPreview .. "Enable FX, "
	elseif C.suffix:find("b") then commitPreview = commitPreview .. "Toggle FX, "
	end

	-- Look for color
	if C.suffix:find("c") then commitPreview = commitPreview.. "Set Color, " end

	if C.renaming then commitPreview = commitPreview .. "Rename, " end
	if C.prefix == "n" then 
		if commitPreview == "" then
			commitPreview = "Create new track(s), "
		else
			commitPreview = commitPreview:gsub("Toggle ", "") 
			commitPreview = commitPreview:sub(1,-3)
			
			if C.suffix:find('b') then 
				if string.len(C.suffix) < 2 then commitPreview = "New track(s)"
				else
					commitPreview = commitPreview .. "new track(s) "
				end
				commitPreview = commitPreview:gsub("FX", "") 
				commitPreview = commitPreview .. " (FX Bypassed), " 
			else
				commitPreview = commitPreview .. " new tracks, "
			end
		end
	end
	-- look for midi inputs

	if trackCount == -666 then
		display2:AddLine("")
		display2:AddLine("Press F1 to cycle through help pages...", something.r, something.g, something.b)
		return
	end

	if commitPreview ~= "" then commitPreview = commitPreview:sub(1, -3) .. " " end
	display2:AddLine("")
	if trackCount == -1 then
		if cmd.txt:find(">")  then  
			display2:AddLine("Send new track(s) to...", something.r, something.g, something.b)
		elseif cmd.txt:find("<")  then  
			display2:AddLine("New track(s) recieve from...", something.r, something.g, something.b)

		else
			display2:AddLine(commitPreview , something.r, something.g, something.b)
		end
	else
		if commitPreview ~= "" then commitPreview = commitPreview .. "on " end
		display2:AddLine(commitPreview .. trackCount .. " tracks...", something.r, something.g, something.b)
	end


	reaper.PreventUIRefresh(-1)

end

-------------------------------
--Special functions-------------
-------------------------------

local function save_on_exit()
	local file = io.open(script_path .. "soe.dat", 'w')
	io.output(file)
	for h =  20, 1, -1 do
		if C.history[h] then 
			file:write(C.history[h] .. '\n')
		end
	end
	file:close()
end

local function restore_on_load()
	local file = io.open(script_path .. "soe.dat", 'r')
	io.input(file)
	if not file then return end
	for h = 1, 20 do
		local l = file:read()
		if l and l ~= "" then C.history[h] = l end
	end
	file:close()
	C.historySeek = #C.history+1
end

restore_on_load()


local function main_display(page)

	if page == 0 then
		-- display:AddLine("TRACKS", yellow.r, yellow.g, yellow.b)
		-- display:AddLine("")
		-- display:AddLine("Total:", default.r, default.g, default.b, 20)
		-- display:AddLine("")
		-- display:AddLine('Selected:', default.r, default.g, default.b, 20)

		-- display:AddLine("")
		-- display:AddLine("")
		-- display:AddLine("")
		-- display:AddLine("F1     -  Press F1 to cycle through help ", something.r, something.g, something.b)

		display2:CommitPreview(-666)

	elseif page == 1 then 
		display:AddLine("PREFIX COMMANDS", yellow.r, yellow.g, yellow.b)
		display:AddLine("")
		display:AddLine("s       -    Inclusively select tracks ", default.r, default.g, default.b, 50)
		display:AddLine("S       -    Exclusively select tracks ", default.r, default.g, default.b, 50)
		display:AddLine("c       -    Unselect all tracks", default.r, default.g, default.b, 50)
		display:AddLine("c       -    Un-mute/solo/arm/unselect all", default.r, default.g, default.b, 50)
		display:AddLine("D       -    delete selected tracks", default.r, default.g, default.b, 50)
		display:AddLine("n       -    create new tracks", default.r, default.g, default.b, 50)
		
	elseif page == 2 then 

		display:AddLine("SUFFIX COMMANDS", yellow.r, yellow.g, yellow.b)
		display:AddLine("")
		display:AddLine("=m       -    toggle mute", default.r, default.g, default.b, 50)
		display:AddLine("=o       -    toggle solo", default.r, default.g, default.b, 50)
		display:AddLine("=a       -    toggle arm", default.r, default.g, default.b, 50)
		display:AddLine("=b       -    toggle FX", default.r, default.g, default.b, 50)
		display:AddLine("=B       -    toggle FX (include Master)", default.r, default.g, default.b, 50)
		display:AddLine("=c1-16   -    set to custom color", default.r, default.g, default.b, 50)
		display:AddLine("=i       -    set to MIDI input (all)", default.r, default.g, default.b, 50)
		display:AddLine("=I       -    set to Audio Input", default.r, default.g, default.b, 50)
		display:AddLine('="x      -    rename track to "x"', default.r, default.g, default.b, 50)
		display:AddLine("")
		display:AddLine("+/- to specify on or off", default.r, default.g, default.b, 50)
		display:AddLine("Upper Case makes exclusive", default.r, default.g, default.b, 50)
		
	elseif page == 3 then
		display:AddLine("ROUTING COMMANDS", yellow.r, yellow.g, yellow.b)
		display:AddLine("")
		display:AddLine(">        -     send to", default.r, default.g, default.b, 50)
		display:AddLine("<        -     receive from", default.r, default.g, default.b, 50)
		display:AddLine("+        -     add to x or y to auto-increment", default.r, default.g, default.b, 50) 
		display:AddLine("=ax:y    -     route x to y (stereo)", default.r, default.g, default.b, 50)
		display:AddLine("=mx:y    -     route x to y (midi)", default.r, default.g, default.b, 50)
		
		


	elseif page == 4 then

		display:AddLine("HOTKEYS", yellow.r, yellow.g, yellow.b)
		display:AddLine("")
		display:AddLine('Ctrl + Enter to close after command', default.r, default.g, default.b, 40)
		display:AddLine("")
		display:AddLine('Ctrl + Backspace to clear line', default.r, default.g, default.b, 40)
		display:AddLine("")
		display:AddLine('Up/Down arrows to load previous commands (beta)', default.r, default.g, default.b, 40)
		display:AddLine("")
		display:AddLine("ESC to close", default.r, default.g, default.b, 40)

	elseif page == 5 then 
		display:AddLine("EXAMPLES", yellow.r, yellow.g, yellow.b)
		display:AddLine("")
		display:AddLine('Select, toggle arm/solo, and enable FX on "Piano":', default.r, default.g, default.b, 0)
		display:AddLine("")
		display:AddLine('s Piano =ab+o', green.r, green.g, green.b, 50)
		display:AddLine("")
		display:AddLine('Send A, B, & Cs MIDI Ch 1 to Kontakt Ch 1, Ch2, Ch 3', default.r, default.g, default.b, 0)
		display:AddLine("")
		display:AddLine('s A, B, C > Kontakt=m1+:1', green.r, green.g, green.b, 50)
		display:AddLine("")
		display:AddLine('Receive Ch 3/4 from Kontakt to Piano 1/2', default.r, default.g, default.b, 0)
		display:AddLine("")
		display:AddLine('n Piano < Kontakt=a2:1', green.r, green.g, green.b, 50)
	elseif page == 6 then
		display:AddLine("TIPS & TRICKS", yellow.r, yellow.g, yellow.b)
		display:AddLine("")
		display:AddLine('Selected tracks are filtered as you type, therefore', default.r, default.g, default.b, 0)
		display:AddLine('You can easily select multiple tracks, eg:', default.r, default.g, default.b)
		display:AddLine("")
		display:AddLine('s Gtr', green.r, green.g, green.b, 50)
		display:AddLine("")
		display:AddLine('Or continue typing to refine the result:')
		display:AddLine("")
		display:AddLine('s Gtr L', green.r, green.g, green.b, 50)
		display:AddLine("")
		display:AddLine('Track names are sensitive to spaces. Use this to your') 
		display:AddLine('advantge by refining results. For instance,')
		display:AddLine("")
		display:AddLine('s a [space]', green.r, green.g, green.b, 50 )
		display:AddLine("")
		display:AddLine('Would differentiate between "Kontakt" and "Tuba')

	end
end


--Handles resize whenever the refresh threshold is reached
local function gui_size_update()
	frame.w, frame.h = gfx.w-20, gfx.h-25
	cmd.w, cmd.y = frame.w+1, frame.y+frame.h
	display.h = frame.h-60
	display2.y = frame.y+frame.h-40
end

--Loads given table with currently selected tracks
local function update_selected_tracks(selectedTracks)
	update_active_arrange()
	for i = 0, tracks - 1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) and i ~= C.destinationID then selectedTracks[i] = true
		else
			selectedTracks[i] = false
		end
	end
end

--Selects tracks by name
local function select_tracks()
	update_active_arrange()

	reaper.PreventUIRefresh(1)
	local trackCount = 0
	
	display:ClearLines()
	display2:ClearLines()


	for i=0, tracks-1 do
		local t = reaper.GetTrack(0, i )
		local retval, buf = reaper.GetTrackName( t )
		
		local muted = reaper.GetMediaTrackInfo_Value(t, 'B_MUTE')
		local soloed = reaper.GetMediaTrackInfo_Value(t, 'I_SOLO')
		local armed = reaper.GetMediaTrackInfo_Value(t, 'I_RECARM')
		local level = reaper.GetMediaTrackInfo_Value(t, 'I_FOLDERDEPTH')
		local fxBypassed = reaper.GetMediaTrackInfo_Value(t, "I_FXEN")



		local levelMod = ""
		local r, g, b = 0,0,0
		if soloed == 1 then r, g, b = yellow.r, yellow.g, yellow.b
		elseif muted == 1  then r, g, b = red.r, red.g, red.b
		elseif armed == 1 then r, g, b = green.r, green.g, green.b
		elseif fxBypassed == 0 then r, g, b = grey.r, grey.g, grey.b
		else r, g, b = default.r, default.g, default.b
		end

		

		if level == 1 then levelMod = " |F|" else levelMod = "" end

	
		if C.trackNumbers[1] == i+1 then 
			reaper.SetTrackSelected( t, true ) 
			display:AddLine(i+1 .. ": " .. buf:sub(1,14) .. levelMod, r, g, b)
			trackCount = trackCount + 1
		--if the string is an exact match	
		elseif string.lower(buf) == C.targets[1] or string.lower(buf .. " ") == C.targets[1] or string.lower(buf .. "  ") == C.targets[k] then 
			reaper.SetTrackSelected( t, true ) 
			display:AddLine(i+1 .. ": " .. buf:sub(1,14) .. levelMod, r, g, b)
			trackCount = trackCount + 1

		else 
			--finds close matches
			if string.lower(buf):match(C.targets[1]) and string.lower(buf .. " ") ~= C.targets[1] then 
				reaper.SetTrackSelected( t, true ) 
				display:AddLine(i+1 .. ": " .. buf:sub(1,14) .. levelMod, r, g, b)
				trackCount = trackCount + 1
			

			--if i is not a match deselect
			else 
				reaper.SetTrackSelected( t, false) 

			end
		end
	
	end

	display2:CommitPreview(trackCount)

end



--Selects destination by name
local function select_destination(sources)
	update_active_arrange()

	reaper.PreventUIRefresh(1)
	
	
	display:ClearLines()
	display2:ClearLines()


	for i=0, tracks-1 do
		local t = reaper.GetTrack(0, i )
		local retval, buf = reaper.GetTrackName( t )
		
		local muted = reaper.GetMediaTrackInfo_Value(t, 'B_MUTE')
		local soloed = reaper.GetMediaTrackInfo_Value(t, 'I_SOLO')
		local armed = reaper.GetMediaTrackInfo_Value(t, 'I_RECARM')
		local level = reaper.GetMediaTrackInfo_Value(t, 'I_FOLDERDEPTH')
		local fxBypassed = reaper.GetMediaTrackInfo_Value(t, "I_FXEN")


		local levelMod = ""
		local r, g, b = 0,0,0
		if soloed == 1 then r, g, b = yellow.r, yellow.g, yellow.b
		elseif muted == 1  then r, g, b = red.r, red.g, red.b
		elseif armed == 1 then r, g, b = green.r, green.g, green.b
		elseif fxBypassed == 0 then r, g, b = grey.r, grey.g, grey.b
		else r, g, b = default.r, default.g, default.b
		end

		

		if level == 1 then levelMod = " |F|" else levelMod = "" end

	
		if C.destinationNumber == i+1 then 
			reaper.SetTrackSelected( t, true ) 
			display:AddLine(i+1 .. ": " .. buf:sub(1,14) .. levelMod, r, g, b)
			C.destinationID = i
			
		--if the string is an exact match	
		elseif string.lower(buf) == C.destinationInput or string.lower(buf .. " ") == C.destinationInput or string.lower(buf .. "  ") == C.destinationInput then 
			reaper.SetTrackSelected( t, true ) 
			display:AddLine(i+1 .. ": " .. buf:sub(1,14) .. levelMod, r, g, b)
			C.destinationID = i
			

		else 
			--finds close matches
			if string.lower(buf):match(C.destinationInput) and string.lower(buf .. " ") ~= C.destinationInput then 
				reaper.SetTrackSelected( t, true ) 
				display:AddLine(i+1 .. ": " .. buf:sub(1,14) .. levelMod, r, g, b)
				C.destinationID = i
				
			

			--if i is not a match deselect
			else 
				reaper.SetTrackSelected( t, false) 

			end
		end


	
	end



	display2:CommitPreview(-1, sources)
	

end


--Restores the selection if user cancels command
local function restore_selected_tracks()
	for i = 0, tracks-1 do
		reaper.SetTrackSelected(reaper.GetTrack(0, i), prevSelectedTracks[i])
	end
end

--Sets selected tracks param with state 
local function set_selected_tracks(param, state)
	update_active_arrange()

	if C.suffix:find('B') then reaper.SetMediaTrackInfo_Value(reaper.GetMasterTrack(0), param, math.abs(reaper.GetMediaTrackInfo_Value( reaper.GetMasterTrack(0), param)-1)) end

	for i = 0, tracks-1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) and i ~= C.destinationID then 

			if state == -1 then
				reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, i), param, math.abs(reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), param)-1))

			else
				reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), param, state)
			end
		end

		--if exclusive mode then fuck this track in it's asshole
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) == false and C.exclusive then 
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
	if not C.engaged and cmd.txt ~= "" then 
		update_selected_tracks(prevSelectedTracks)
		C.engaged = true
	end

	----------------------------
	--While typing -------------
	----------------------------
	--Look for various prefix commands
	if cmd.active and C.prefix == "s" then 
		select_tracks()

	elseif cmd.active and C.prefix == "S" then
		C.exclusive = true
		select_tracks()
	elseif cmd.active and C.prefix == "n" then
		reaper.Main_OnCommand(40297, 0)
		display2:ClearLines()
		display2:CommitPreview(-1, sources)
	elseif cmd.active and C.prefix == "D" then
		select_tracks()		
	elseif cmd.active and C.prefix == "=" and cmd.txt ~= "" then 
		C.suffix = cmd.txt:sub(cmd.txt:find("=")+1)
		C:Parse()

	end

	if  not cmd.txt:find(">") and not cmd.txt:find("<") then
		update_selected_tracks(sources) 
	end

	if (cmd.active and cmd.txt:find(">")) or (cmd.active and cmd.txt:find("<")) then
		select_destination(sources)
	end

	if cmd.active and C.prefix == "=" then
		display2:ClearLines()
		display2:CommitPreview(reaper.CountSelectedTracks(0))
	end

	-------------------------------
	--Committed Input Handling-----
	-------------------------------
	if cmd.returned then 
		reaper.PreventUIRefresh(1)
		reaper.Undo_BeginBlock()
		helppage = 0

		--Adds the committed input to the history

		table.insert(C.history, cmd.txt)
		C.historySeek = count_table(C.history)+1

		--Look for create track
		if C.prefix == "n" then
			
			C.exclusive = true
			


			for i = 1, count_table(C.targets) do
				local totalTracks = reaper.CountTracks(0)
				reaper.InsertTrackAtIndex(totalTracks, true)
				reaper.GetSetMediaTrackInfo_String( reaper.GetTrack(0, totalTracks), 'P_NAME', C.targets[i], true )
				reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0, totalTracks), 'I_RECMON', 1 )
				reaper.SetTrackSelected(reaper.GetTrack(0, totalTracks), true)
			end
			update_selected_tracks(sources)
			
		--if there was an attempt to name (ie., ="sometext") then name the selected tracks
		elseif C.renaming and (cmd.txt:sub(1,1) == "s" or cmd.txt:sub(1,1) == "S") and reaper.CountSelectedTracks(0) >= 1 then 
			for i = 0, tracks-1 do
				track = reaper.GetTrack(0, i)
				if reaper.IsTrackSelected(track) then
					reaper.GetSetMediaTrackInfo_String( reaper.GetTrack(0, i), 'P_NAME', C.renaming, true )
				end
				
			end
			C.renaming = nil 
		end


		if cmd.active and C.prefix == "C" then
			
			for i = 0, tracks - 1 do
				track = reaper.GetTrack(0, i)
				reaper.SetMediaTrackInfo_Value(track, 'B_MUTE', 0)
				reaper.SetMediaTrackInfo_Value(track, 'I_SOLO', 0)
				reaper.SetMediaTrackInfo_Value(track, 'I_RECARM', 0)
				reaper.SetTrackSelected(track, false)
				C.exclusive = true
			end
		elseif cmd.active and C.prefix == "c" then
			for i = 0, tracks - 1 do
				track = reaper.GetTrack(0, i)
				reaper.SetTrackSelected(track, false)
				C.exclusive = true
			end
		end

		if C.prefix == "D" then
			
			for tr = tracks-1, 0, -1 do
				if reaper.IsTrackSelected(reaper.GetTrack(0,tr)) then reaper.DeleteTrack(reaper.GetTrack(0, tr)) end
			end	


		end



		--Look for mute 
		if C.suffix:find("m%-") then set_selected_tracks('B_MUTE', 0, false)
		elseif C.suffix:find("m%+") then set_selected_tracks('B_MUTE', 1, false)
		elseif C.suffix:find("m") then set_selected_tracks('B_MUTE',-1, false)
		elseif C.suffix:find("M") then set_selected_tracks('B_MUTE',-1, true)

		end

		--Look for solo
		if C.suffix:find("o%-") then set_selected_tracks("I_SOLO", 0, false)
		elseif C.suffix:find("o%+") then set_selected_tracks('I_SOLO', 1, false)
		elseif C.suffix:find("o") then set_selected_tracks('I_SOLO',-1, false)
		elseif C.suffix:find("O") then set_selected_tracks('I_SOLO', 1, true)
		end

		--Look for arm
		if C.suffix:find("a%-") then set_selected_tracks("I_RECARM", 0, false)
		elseif C.suffix:find("a%+") then set_selected_tracks('I_RECARM', 1, false)
		elseif C.suffix:find("a") then set_selected_tracks('I_RECARM',-1, false)
		elseif C.suffix:find("A") then set_selected_tracks('I_RECARM', 1, true)
		end

		--Look for fx bypass
		if C.suffix:find("b%-") then set_selected_tracks("I_FXEN", 0, false)
		elseif C.suffix:find("b%+") then set_selected_tracks('I_FXEN', 1, false)
		elseif C.suffix:find("b") then set_selected_tracks('I_FXEN',-1, false)
		elseif C.suffix:find("B") then set_selected_tracks('I_FXEN', -1, false)
		end



		--Look for custom color 
		if C.suffix:find("c") then 
			local color = ""
			if C.suffix:find('c%d+') then 	
				color = '_SWS_TRACKCUSTCOL' .. C.suffix:sub(2) 
			else 
				color = "RANDOM"
			end
			if color == "RANDOM" then reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_TRACKRANDCOL'), 0)
			else reaper.Main_OnCommand(reaper.NamedCommandLookup(color), 0)
			end

		end


		--look for record input
		if C.suffix:find("i%d*") then 
			local midiChannel = C.suffix:match("i%d+")
			if midiChannel then midiChannel = midiChannel:sub(2) else midiChannel = 0 end
			set_selected_tracks("I_RECINPUT", 4096 | midiChannel | (63 << 5))
			set_selected_tracks("I_RECMODE", 7)
		end
		if C.suffix:find("I%d*") then 
			local midiChannel = C.suffix:match("i%d+")
			if audioChannel then audioChannel = audioChannel:sub(2) else midiChannel = 0 end
			set_selected_tracks("I_RECINPUT", 0)
			set_selected_tracks("I_RECMODE", 0)
		end


		-- Look for routing
		if C.destinationSuffix then
			reaper.ClearConsole()
			local midiSourceChannel = nil
			local midiDestinationChannel = nil

			local audioSourceChannel = nil
			local audioDestinationChannel = nil

			-- look for midi routing
			if C.destinationSuffix:find("m%d+") then
				midiSourceChannel = C.destinationSuffix:match("m%d+")
			end

			if C.destinationSuffix:find("m%d+%+?:%d+") then
				midiDestinationChannel = C.destinationSuffix:match(":%d+")
			end

			-- Look for audio routing
			if C.destinationSuffix:find("a%d+") then
				audioSourceChannel = C.destinationSuffix:match("a%d+")
			end

			if C.destinationSuffix:find("a%d+%+?:%d+") then
				audioDestinationChannel = C.destinationSuffix:match(":%d+")
			end


			if midiSourceChannel then midiSourceChannel = midiSourceChannel:sub(2) else midiSourceChannel = 0 end
			if midiDestinationChannel then midiDestinationChannel = midiDestinationChannel:sub(2) else midiDestinationChannel = 0 end

			if audioSourceChannel then audioSourceChannel = audioSourceChannel:sub(2) else audioSourceChannel = 0 end
			if audioDestinationChannel then audioDestinationChannel = audioDestinationChannel:sub(2) else audioDestinationChannel = 0 end
			
			audioSourceChannel = audioSourceChannel - 1
			audioDestinationChannel = audioDestinationChannel - 1
			audioSourceChannel = audioSourceChannel + audioSourceChannel
			audioDestinationChannel = audioDestinationChannel + audioDestinationChannel
			
			for tr = 0, tracks-1 do

				if sources[tr] == true then 
					 retval, buf = reaper.GetTrackName( reaper.GetTrack(0, tr))
					 --cons('\n' .. buf .. "\n" )
					if cmd.txt:find(">") then
						reaper.CreateTrackSend(reaper.GetTrack(0, tr), reaper.GetTrack(0,C.destinationID))
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), 0, reaper.GetTrackNumSends(reaper.GetTrack(0, C.destinationID), 0) , 'I_MIDI_SRCCHAN', true, tonumber(midiSourceChannel)) 
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), 0, reaper.GetTrackNumSends(reaper.GetTrack(0, C.destinationID), 0) , 'I_MIDI_DSTCHAN', true, tonumber(midiDestinationChannel))
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), 0, reaper.GetTrackNumSends(reaper.GetTrack(0, C.destinationID), 0) , 'I_SRCCHAN', true, tonumber(audioSourceChannel)) 
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), 0, reaper.GetTrackNumSends(reaper.GetTrack(0, C.destinationID), 0) , 'I_DSTCHAN', true, tonumber(audioDestinationChannel))

						if C.destinationSuffix:find("m%d+%+:") then midiSourceChannel = midiSourceChannel + 1 end
						if C.destinationSuffix:find("m%d+%+?:%d+%+") then midiDestinationChannel = midiDestinationChannel + 1 end

						if C.destinationSuffix:find("a%d+%+:") then audioSourceChannel = audioSourceChannel + 2 end
						if C.destinationSuffix:find("a%d+%+?:%d+%+") then audioDestinationChannel = audioDestinationChannel + 2 end
					
					elseif cmd.txt:find("<") then
						reaper.CreateTrackSend(reaper.GetTrack(0,C.destinationID), reaper.GetTrack(0, tr))
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), -1, reaper.GetTrackNumSends(reaper.GetTrack(0, tr), 0) , 'I_MIDI_SRCCHAN', true, tonumber(midiSourceChannel)) 
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), -1, reaper.GetTrackNumSends(reaper.GetTrack(0, tr), 0) , 'I_MIDI_DSTCHAN', true, tonumber(midiDestinationChannel))
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), -1, reaper.GetTrackNumSends(reaper.GetTrack(0, tr), 0) , 'I_SRCCHAN', true, tonumber(audioSourceChannel)) 
						reaper.BR_GetSetTrackSendInfo(reaper.GetTrack(0, tr), -1, reaper.GetTrackNumSends(reaper.GetTrack(0, tr), 0) , 'I_DSTCHAN', true, tonumber(audioDestinationChannel))
						
						if C.destinationSuffix:find("m%d+%+:") then midiDestinationChannel = midiDestinationChannel + 1 end
						if C.destinationSuffix:find("m%d+%+?:%d+%+") then midiSourceChannel = midiSourceChannel + 1 end

						if C.destinationSuffix:find("a%d+%+:") then audioDestinationChannel = audioDestinationChannel + 2 end	
						if C.destinationSuffix:find("a%d+%+?:%d+%+") then audioSourceChannel = audioSourceChannel + 2 end						

					end

				end

			end
		
		end



		reaper.PreventUIRefresh(-1)
		--Clear cmd, clear engage, clear returned, clear flags
		--commit the currently selected tracks to previous selected tracks
		--reset recall 

		if reaper.CountSelectedTracks(0) >=1 then reaper.SetMixerScroll( reaper.GetSelectedTrack(0, 0)) end
		cmd.txt = ""
		cmd.returned = false

		if not C.exclusive then 
			update_selected_tracks(curSelectedTracks)
			for i = 0, tracks -1 do
				if prevSelectedTracks[i] == true or curSelectedTracks[i] == true then
					reaper.SetTrackSelected( reaper.GetTrack(0,i), true )
				else
					reaper.SetTrackSelected( reaper.GetTrack(0,i), false )
				end
			end
		end


		update_selected_tracks(prevSelectedTracks)
		C:Reset()
		C.historySeek = count_table(C.history)+1

	end

end

gui_size_update()

function main()

	--Draws all elements
	fill_background()
	draw_elements()


	local char = gfx.getchar()
	if char == 27 or char == -1  or C.exitOnCommand then 
		save_on_exit()
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
		elseif (char == 8 and gfx.mouse_cap == 04) or (C.engaged and cmd.txt == "" ) then 
			cmd.txt = ""
			
			restore_selected_tracks()
			C.engaged = false
	
		--if up arrow
		elseif char == 30064 then 
			C:PrevCMD()
			
		--if down arrow	
		elseif char == 1685026670 then

			C:NextCMD()
			
		else --user is typing
			--if the user presses ctrl+enter then exit after commit
			if gfx.mouse_cap == 04 and char == 13 then C.exitOnCommand = true end

			-- Send characters to the textfield
			cmd:Change(char)
			update_cmd(char)
			C:Parse()

			--if not c.engaged then reset_display() end
			if not C.engaged then 
				display:ClearLines()
				display2:ClearLines() 
				if char == 26161 then helppage = (helppage + 1)%7 end
				main_display(helppage)
			end
		--if the user isn't scrolling through the history then set c.cmd[1]
			if C.historySeek == count_table(C.history)+1 then C.txt = cmd.txt end


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

	if reaper.JS_Window_GetFocus() == win then 
		reaper.JS_Window_SetOpacity( win, 'ALPHA',  1) 

	else
		reaper.JS_Window_SetOpacity(win, 'ALPHA', .85)
	end
	
	-- reaper.ClearConsole()
	-- cons("\nText: " .. C.txt)
	-- if C.prefix then cons("\nPrefix: " .. C.prefix) end
	-- if C.suffix then cons("\nSuffix: " .. C.suffix) end
	-- if C.targets then
	-- 	for t=1, count_table(C.targets) do
	-- 		cons("\n Target " .. t .. ": " .. C.targets[t])
	-- 	end
	-- end


end
main()
reaper.Undo_EndBlock("Something wicked", -1)