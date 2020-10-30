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
update_active()

function mouse_click()


	if reaper.JS_Mouse_GetState(0x0008) == 0x0008 and reaper.JS_Mouse_GetState(1) == 1 then  -- Shift 
		mousedown = true
		clickType = 9
	end

	if reaper.JS_Mouse_GetState(0x0004) == 0x0004 and reaper.JS_Mouse_GetState(1) == 1 then  -- Ctrl 
		mousedown = true
		clickType = 5
	end
	
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
	
	for i = 0, notes-1 do
		retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
		retval2, selected2, muted2, startppqpos2, endppqpos2, chan2, pitch2, vel2 = reaper.MIDI_GetNote( take, i+1 )
		if selected and selected2 == false then 
			reaper.MIDI_SetNote(take, i, false, false, startppqpos, endppqpos, chanIn, pitchIn, velIn, true)
			break 
		end
	end
end

------------------------
--Start the useful stuff
------------------------


function main()

	ms = mouse_click()
	selectedNotes = 0

	if ms == 1 then 
		update_active()
	
		for s = 0, notes-1 do
			sretval, sselected, smuted, sstartppqpos, sendppqpos, schan, spitch, svel = reaper.MIDI_GetNote( take, s )
			if sselected then selectedNotes = selectedNotes+1 end
		end

		if note_under_mouse_index() == nil then 
		if selectedNotes = 3 then i
			if note_under_mouse_index() == 1 then unselect_right()
			elseif note_under_mouse_index == 3 then unselect_left()
			end
		elseif note_under_mouse_index() >= selectedNotes/2 then unselect_left() 
		elseif note_under_mouse_index() <= selectedNotes/2 then unselect_right()
		end

			
		reaper.MIDI_Sort(take)
		mousedown = false

	end

	reaper.defer(main)

	

end
	-----------------------------
	--Debugging Stuff
	--cons("Note Row: " .. noteRow .. "\nMouse time pos: " .. mouse_time_pos .. "\nMouse Time Snapped: " .. reaper.SnapToGrid(0, mouse_time_pos)*reaper.MIDI_GetGrid(take), true)
--	med = reaper.MIDI_GetGrid(take)

	-----------------------------


main()
reaper.Undo_EndBlock2(0, "Unselect leftmost", 0)
