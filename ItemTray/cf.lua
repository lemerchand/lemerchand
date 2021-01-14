
function cons(text, p)
	if p == true then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(text))
end

function get_open_MEWS()
	 local retval, list = reaper.JS_MIDIEditor_ListAll()
	 local parsedlist = {}
	 
	 while true do
	 	local t = list:match('%w*')
	 	table.insert(parsedlist, reaper.JS_Window_HandleFromAddress( t ))
	 	list = list:gsub(t .. ',?', '')
	 	if list == '' then break end
	 end
	 return parsedlist
end

function missing_item(b, i)

	b:Remove(false, i)	
	
	local candidates = {}
	local itemcount = reaper.CountMediaItems(0)
	for i = 0, itemcount-1 do
		local tk = reaper.GetActiveTake(reaper.GetMediaItem(0,i))
 		local retval, candidate = reaper.GetSetMediaItemTakeInfo_String( tk, 'P_NAME', '' , false)
		if candidate:find(b.name .. '%p?glued') then 
			table.insert(candidates, {name=candidate, take=tk})
		end
	end 		

 	if #candidates > 0 then 

 		for i, candidate in ipairs(candidates) do
			local replace = reaper.MB(b.name .. ' has been modified. Would you like to replace it with ' .. candidate.name .. '?', 'Replace ' .. b.name .. '?', 4)

			if replace == 6 then 
				
				reaper.SetMediaItemSelected( reaper.GetMediaItemTake_Item(candidate.take, 'P_ITEM'), true)

				new_bookmark()
				return false
			else 
			end
		end
	else
		reaper.MB(b.name .. ' cannot be found.', "Item missing", 0)
		return false
	end
end

function audio_or_midi(take)
	if reaper.TakeIsMIDI(take) then return  'midi' else
		return  'audio'
	end

end


-----------------------------------
--[			BirdBird Code 		]--
-----------------------------------

function midi_to_audio(source,item)
	
	--unselect all tracks
	reaper.Main_OnCommand(40297, 0)
	reaper.SelectAllMediaItems(0, false)

	reaper.SetMediaItemSelected(source, true)
	local take = reaper.GetMediaItemTake(item, 0)

	local noteCount = reaper.MIDI_CountEvts(take)
	for i = 0, noteCount-1 do
	    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
	    local timePos = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos)
	    reaper.ApplyNudge( 0, --project, 
	    1,--nudgeflag, 
	    5,--nudgewhat, 
	    1,--nudgeunits, 
	    timePos, --value, 
	    0,--reverse, 
	    1)--copies )
	end

end
