function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../libs/gui.lua')
reaperDoFile('../libs/cf.lua')



gfx.init("Lemerchand Testing", 850,650, false, 100,500)
local win = reaper.JS_Window_Find("Lemerchand Testing", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

status = Status:Create(10,10,280,350)

local lastChar = 0


function insert_random_notes()

	update_active_midi()
	local takeLength = reaper.BR_GetMidiSourceLenPPQ( take )

	local amount  = math.random(0,25)

	for n = 0, amount do
		local row = math.random(75, 125)
		local ppq = math.random(0,takeLength-30) 
		ppq = ppq - (ppq%120)
		reaper.MIDI_InsertNote(take, true, false, ppq, ppq+240, 1, row, 80, true)
	end
	reaper.MIDI_Sort(take)
end




local btn_randomNotes = Button:Create(status.x+10, status.y+status.h+30, "Test")

local cmd = TextField:Create(20, 250, status.w-20, 20, "Enter Some text: ", "", false, false)
local t2 = Display:Create(20, 105, status.w-20,110)
local log = Text:Create(20, 150, "", "", nil, nil, nil, nil, nil, false, status.w-20, 90)
t2:AddLine("Violin overdub: " , 1, 0, 1)
t2:AddLine("Hot Sauce FTW: " , 0,1,0)




function main()

	-- Clear text
	local statustext = "" 
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



	local mousex, mousey = reaper.GetMousePosition()
	local projmouse= reaper.BR_GetMouseCursorContext_Position()

	local window, segment, details = reaper.BR_GetMouseCursorContext()
	update_active_arrange()	

	local statustext = statustext .. "             --==  GENERAL  ==--" ..
								"\nMouse x: " .. mousex .. " Mouse y: " .. mousey ..
								"\nProj Mouse x: " .. projmouse .. 
								"\nMouse Cap: " .. reaper.JS_Mouse_GetState(-1) ..
								"\nLast Character: " .. lastChar .. 
								"\nContext: " .. window ..
								"\nTotal tracks: " .. tracks

	if window == "midi_editor" then 
		update_active_midi()
		local selectedNotes = 0

		for i = 0, notes-1 do
			retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
			if selected then selectedNotes = selectedNotes + 1 end
		end
		statustext = statustext .. "\n\n             --== MIDI Editor ==--" ..
								"\nTotal Notes: " .. notes .. 
								"\nSelected Notes: " .. selectedNotes

	end

 	

	--Draws all elements
	draw_elements()
	if char ~= 0 then lastChar = char end
	



if btn_randomNotes.leftClick then insert_random_notes() end
	if cmd.leftClick then cmd.active = true end

	if cmd.active and cmd.txt == "s" then 

		-- for i=0, tracks-1 do
		-- 	local t = reaper.GetTrack(0, i )
		-- 	local retval, buf = reaper.GetTrackName( t )

		-- 	if buf == "Track 1" then cons(buf .. "\n") end
		-- end

		log.txt = "Select: " 

	end
	if cmd.returned then 

		--Look for commands

		if cmd.txt == "hello" then log.txt = "HI!"
		else
			-- Log the command and reset the textfield
			log.txt = log.txt .. "\n" .. cmd.txt

		end
		cmd.txt = ""
		cmd.returned = false
	end

	status:Display(statustext)
	
end
main()