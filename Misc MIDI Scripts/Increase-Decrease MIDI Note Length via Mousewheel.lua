--Load commonf functions library
function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../cf.lua')


--Setup an undo block
reaper.Undo_BeginBlock2(0)

----------------------
--Get neccessary info
---------------------
selected_notes = 0
update_active()

-- Look to see if there are selected notes
-- If so flag selected_notes to run the appropraite if in main()

for i = 0, notes-1 do
	retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	if selected then  selected_notes = 1
	break
	end
end

-- Get the curoris context, and mouse position
-- If there are selected notes then don't bother
if selected_notes == 0 then 
	window, segment, details = reaper.BR_GetMouseCursorContext()
	retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()
	mouse_time_pos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.BR_GetMouseCursorContext_Position()) --mouse time in ppq
end

------------------------
--Start the useful stuff
------------------------
function main()
	--Get mousewheel (val)
	is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()

	--If notes are selected get mouse time and position
	if selected_notes == 0 then
		 for ii = 0, notes-1 do
			retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, ii )
			if pitch == noteRow and mouse_time_pos >= startppqpos and mouse_time_pos <= endppqpos then
				new_endppqpos = endppqpos + (val*8)
				reaper.MIDI_SetNote(take, ii, false, false, startppqpos, new_endppqpos, chanIn, pitchIn, velIn, true)
			end
		 end
	--Otherwise, go for selected notes
	else
		for i = 0, notes-1 do
			retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
			if selected then 
				new_endppqpos = endppqpos + (val*8)
				reaper.MIDI_SetNote(take, i, true, false, startppqpos, new_endppqpos, chanIn, pitchIn, velIn, true)
			end
		end
	end

	reaper.MIDI_Sort(take)

	-----------------------------
	--Debugging Stuff
	--cons("Note Row: " .. noteRow .. "\nMouse time pos: " .. mouse_time_pos .. "\nMouse Time Snapped: " .. reaper.SnapToGrid(0, mouse_time_pos)*reaper.MIDI_GetGrid(take), true)
--	med = reaper.MIDI_GetGrid(take)

	-----------------------------

	--Run main() until the mousewheel is no longer used
	if val == 0 then 
		--cons("end", true)
		return else reaper.defer(main)end
end

main()
reaper.Undo_EndBlock2(0, "Midi Note Length via Mousewheel", 0)
