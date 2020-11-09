reaper.Undo_BeginBlock2(0)


active_midi_editor = reaper.MIDIEditor_GetActive()
take = reaper.MIDIEditor_GetTake(active_midi_editor)
retval, notes, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts( take )
window, segment, details = reaper.BR_GetMouseCursorContext()
local  retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()


for i = 0, notes-1 do

	retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	if selected then 
		
		reaper.MIDI_SetNote(take, i, true, false, startppqpos, endppqpos, chan, noteRow, vel, true)
	end
end



reaper.MIDI_Sort(take)

reaper.Undo_EndBlock2(0, "Move selected notes to row under mouse", -1)