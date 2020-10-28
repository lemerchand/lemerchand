--Load commonf functions library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../cf.lua')


--Setup an undo block
reaper.Undo_BeginBlock2(0)

----------------------
--Get neccessary info
---------------------

update_active()

------------------------
--Start the useful stuff
------------------------
local mousedown = false

function main()

 	
	if reaper.JS_Mouse_GetState(1) == 1 and mousedown == false then mousedown = true 

	elseif reaper.JS_Mouse_GetState(0) == 0 and reaper.JS_Mouse_GetState(1) ~= 1 and mousedown == true then 

		for i = 0, notes-1 do
			retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
			if selected then 
				reaper.MIDI_SetNote(take, i, false, false, startppqpos, endppqpos, chanIn, pitchIn, velIn, true)
				break
			elseif i == notes-1 and selected == false then  return 
			end
		end
		
		
		reaper.MIDI_Sort(take)
		mousedown = false

	end

	
	if reaper.JS_Mouse_GetState(2) == 2 then 
	
		return
	else
		reaper.defer(main)

	end

end
	-----------------------------
	--Debugging Stuff
	--cons("Note Row: " .. noteRow .. "\nMouse time pos: " .. mouse_time_pos .. "\nMouse Time Snapped: " .. reaper.SnapToGrid(0, mouse_time_pos)*reaper.MIDI_GetGrid(take), true)
--	med = reaper.MIDI_GetGrid(take)

	-----------------------------


main()
reaper.Undo_EndBlock2(0, "Unselect leftmost", 0)
