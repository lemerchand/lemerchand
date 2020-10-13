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
	end
reaper.MIDI_Sort(take)
end