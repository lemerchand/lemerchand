reaper.Undo_BeginBlock2(0)

--Get pertinent information
active_midi_editor = reaper.MIDIEditor_GetActive()
take = reaper.MIDIEditor_GetTake(active_midi_editor)
retval, notes, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts( take )
window, segment, details = reaper.BR_GetMouseCursorContext()
local  retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()


--Look through all notes
for i = 0, notes-1 do

	retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	retval, selected2, muted2, startppqpos2, endppqpos2, chan2, pitch2, vel2 = reaper.MIDI_GetNote( take, i+1 )
	if selected then 

		if endppqpos >= startppqpos2 then endppqpos = startppqpos2 - 1 end

		--Move selected notes to note row
		reaper.MIDI_SetNote(take, i, true, false, startppqpos, endppqpos, chan, noteRow, vel, true)
	end
end


--Apply changes
reaper.MIDI_Sort(take)

--Workaround to get script entered into the undo history
local id = reaper.GetMediaItemTakeInfo_Value( take, 'P_ITEM')
local track = reaper.GetMediaItemTakeInfo_Value( take, 'P_TRACK')
reaper.MarkTrackItemsDirty(track, id)
reaper.Undo_EndBlock2(0, "Move selected notes to row under mouse", -1)