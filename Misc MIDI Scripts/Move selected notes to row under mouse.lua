reaper.Undo_BeginBlock2(0)
reaper.ClearConsole()

--Get pertinent information
local active_midi_editor = reaper.MIDIEditor_GetActive()
local take = reaper.MIDIEditor_GetTake(active_midi_editor)
local retval, notes, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts( take )
local window, segment, details = reaper.BR_GetMouseCursorContext()
local retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()

--Check to see if overlap correction is enabled
local overlapCorrectIsOn = reaper.GetToggleCommandStateEx(32060, 40681)
--If so, turn that stupid ass shit off!
if overlapCorrectIsOn == 1 then reaper.MIDIEditor_OnCommand(active_midi_editor, 40681) end

--Look through all notes
for i = 0, notes-1 do

	-- Get current note and one lookahead note
	local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	local retval, selected2, muted2, startppqpos2, endppqpos2, chan2, pitch2, vel2 = reaper.MIDI_GetNote( take, i+1 )
	if selected then 

		--If the note overlaps with the next note and the next note is selected
		--Checking for the second note's selected status is impreative since lua will return true if there is no next note
		if endppqpos > startppqpos2 and selected2 then
			endppqpos = startppqpos2 - 1 
		end

		--If the notes are at the same time 
		if startppqpos == startppqpos2 then
			--Delete both notes and insert a new one at note2's position
			--Don't ask me why this works
			reaper.MIDI_InsertNote(take, true, false, startppqpos2, endppqpos2, chan, noteRow, vel, true)
			reaper.MIDI_DeleteNote(take, i+1)
			reaper.MIDI_DeleteNote(take, i) 
		
		--Otherwise proceed as normal
		else
			--Insert the the new note, delete the old one
			reaper.MIDI_InsertNote(take, true, false, startppqpos, endppqpos, chan, noteRow, vel, true)
			reaper.MIDI_DeleteNote(take, i)
		end
	end
end

--Delete leftover notes
for i = 0, notes-1 do
	local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	if selected and pitch ~= noteRow then reaper.MIDI_DeleteNote(take, i) end
end


--Apply changes and re-enabled overlap correction if it was on on init
reaper.MIDI_Sort(take)
if overlapCorrectIsOn == 1 then reaper.MIDIEditor_OnCommand(active_midi_editor, 40681) end


--Workaround to get script entered into the undo history
local id = reaper.GetMediaItemTakeInfo_Value( take, 'P_ITEM')
local track = reaper.GetMediaItemTakeInfo_Value( take, 'P_TRACK')
reaper.MarkTrackItemsDirty(track, id)
reaper.Undo_EndBlock2(0, "Move selected notes to row under mouse", -1)
