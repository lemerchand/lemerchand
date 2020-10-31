--Load commonf functions library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../cf.lua')


--Setup an undo block
reaper.Undo_BeginBlock2(0)

----------------------
--Setup
---------------------
local mousedown = false
local clickType = 0
update_active_midi()

function mouse_click()


	
	if reaper.JS_Mouse_GetState(1) == 1 then
		mousedown = true
		clickType = 1
	end

	if reaper.JS_Mouse_GetState(0) == 0 and reaper.JS_Mouse_GetState(1) ~= 1 and mousedown then 
	mousedown = false
	return clickType
	end

	if reaper.JS_Mouse_GetState(0) == 0 and mousedown == false then
	return 0
	end
end

function unselect_left()
	
	for i = 0, notes-1 do
		retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
		if selected then 
			reaper.MIDI_SetNote(take, i, false, false, startppqpos, endppqpos, chanIn, pitchIn, velIn, true)
			break
		elseif i == notes-1 and selected == false then  
			return 
		end
	end
end

function unselect_right()
	
	for i = notes-1, 0, -1 do
		retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
		
		if selected  then 
			reaper.MIDI_SetNote(take, i, false, false, startppqpos, endppqpos, chanIn, pitchIn, velIn, true)
			break 
		end
	end
end

------------------------
--Start the useful stuff
------------------------


function main()

	reaper.JS_Mouse_SetCursor( reaper.JS_Mouse_LoadCursor(188))
	reaper.JS_WindowMessage_Intercept(reaper.JS_Window_GetFocus(), "WM_SETCURSOR", false)
	ms = mouse_click()
	selectedNotes = 0

	if ms == 1 then 
		update_active_midi()
	
		for s = 0, notes-1 do
			sretval, sselected, smuted, sstartppqpos, sendppqpos, schan, spitch, svel = reaper.MIDI_GetNote( take, s )
			if sselected then selectedNotes = selectedNotes+1 end
		end

		if note_under_mouse_index() == nil then goto pass

		elseif note_under_mouse_index() >= selectedNotes/2 then unselect_left() 
		elseif note_under_mouse_index() <= selectedNotes/2 then unselect_right()
		end

			
		reaper.MIDI_Sort(take)
		
		::pass::
		mousedown = false

	end
	
	--check to see if any selected ntoes remain, if not then end
	for s = 0, notes-1 do
			sretval, sselected, smuted, sstartppqpos, sendppqpos, schan, spitch, svel = reaper.MIDI_GetNote( take, s )
			if sselected then selectedNotes = selectedNotes+1 end
		end

	if selectedNotes == 0 then 
		reaper.atexit(reaper.JS_WindowMessage_ReleaseAll())
		return

	else reaper.defer(main) end

end


main()
reaper.Undo_EndBlock2(0, "Unselect note from opposite side of selected notes.", 0)
