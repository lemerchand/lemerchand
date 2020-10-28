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
function main()
	--Get mousewheel (val)
	is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()

	
			
	for i = 0, notes-1 do
		retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
		if selected then 
			reaper.MIDI_SetNote(take, i, false, false, startppqpos, endppqpos, chanIn, pitchIn, velIn, true)
			break
		end
	end

	reaper.MIDI_Sort(take)
end
	-----------------------------
	--Debugging Stuff
	--cons("Note Row: " .. noteRow .. "\nMouse time pos: " .. mouse_time_pos .. "\nMouse Time Snapped: " .. reaper.SnapToGrid(0, mouse_time_pos)*reaper.MIDI_GetGrid(take), true)
--	med = reaper.MIDI_GetGrid(take)

	-----------------------------


main()
reaper.Undo_EndBlock2(0, "Unselect leftmost", 0)
