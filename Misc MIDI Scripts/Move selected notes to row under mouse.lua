reaper.Undo_BeginBlock2(0)

--Get pertinent information
local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
local retval, notes, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts( take )
local window, segment, details = reaper.BR_GetMouseCursorContext()
local retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()


--Look through all notes
for i = 0, notes-1 do

	-- Get current note and one lookahead note
	local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	local retval, selected2, muted2, startppqpos2, endppqpos2, chan2, pitch2, vel2 = reaper.MIDI_GetNote( take, i+1 )
	if selected then 

		--If the note overlaps with the next and it ISNT the last selected note
		if endppqpos >= startppqpos2 and i ~= notes-1 then endppqpos = startppqpos2 - 1 end
		if startppqpos == startppqpos2 then reaper.MIDI_DeleteNote(take, i)
		else
		--Insert the the new note, delete the old one
		reaper.MIDI_InsertNote(take, true, false, startppqpos, endppqpos, chan, noteRow, vel, true)
		reaper.MIDI_DeleteNote(take, i)
		end
	end
end


--Apply changes
reaper.MIDI_Sort(take)

--Workaround to get script entered into the undo history
local id = reaper.GetMediaItemTakeInfo_Value( take, 'P_ITEM')
local track = reaper.GetMediaItemTakeInfo_Value( take, 'P_TRACK')
reaper.MarkTrackItemsDirty(track, id)
reaper.Undo_EndBlock2(0, "Move selected notes to row under mouse", -1)
