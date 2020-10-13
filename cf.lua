function notes_list_not_empty()
	
	for i = 1, 12 do
		reaper.ShowConsoleMsg(notes_list[i])
		if notes_list[i] == 1 then return true end
	end
	return false

end

function is_note_in(n)
	for i = 1, 12 do
		if notes_list[i] == n then return true end
	end
end

function select_notes(clear, min_vel, max_vel)
	item = reaper.GetSelectedMediaItem(0, 0)
	take = reaper.GetActiveTake(item)
	notes = reaper.MIDI_CountEvts(take)

	if clear then reaper.MIDI_SelectAll(take, false) end

	for i = 0, notes-1 do
		retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
		if vel >= min_vel and vel <= max_vel then 
			reaper.MIDI_SetNote(take, i, true, false, startppqpos, endppqpos, chan, pitch, vel, true)
		end

		if notes_list_not_empty() == true then
			for n = 1, 12 do
				if is_note_in(notes_list[n]) == 1 and (pitch%12) ~= note_midi_n[n] then
					reaper.MIDI_SetNote(take, i, false, false, startppqpos, endppqpos, chan, pitch, vel, true)

				end
			end
		
		else
			reaper.ShowConsoleMsg("list empty")
		end
			

	end

reaper.MIDI_Sort(take)
end

