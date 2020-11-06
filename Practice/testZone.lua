function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')


gfx.init("Lemerchand Testing", 300,400, false, 1500,600)
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




btn_randomNotes = Button:Create(status.x+10, status.y+status.h-30, "Test")
btn_fadeText = Button:Create(btn_randomNotes.x + btn_randomNotes.w + 20, status.y+status.h-30, "Try")


function main()

	local statustext = ""
	fill_background()

	local char = gfx.getchar()
	if char == 27 or char == -1 then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else reaper.defer(main) end


	mousex, mousey = reaper.GetMousePosition()
	projmouse= reaper.BR_GetMouseCursorContext_Position()

	local window, segment, details = reaper.BR_GetMouseCursorContext()
	update_active_arrange()	

	statustext = statustext .. "             --==  GENERAL  ==--" ..
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
	status:Display(statustext)

	
	if btn_randomNotes.leftClick then insert_random_notes() end

	 
end
main()