
function cons(text, p)
	if p == true then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(text))
end

function clear_all_bookmarks(closeWindow)
	for e = #Elements, 1, -1 do
		if Elements[e].btype == "bookmark" then table.remove(Elements, e) end
	end

	bookmarks = {}
	update_ui()

	if closeWindow then 
		close_all_MEWS()		
	end
end

function load_bookmark(itemGuid, takeGuid, savedgroups)

	local item = reaper.BR_GetMediaItemByGUID(0, itemGuid)
	local take = reaper.GetMediaItemTakeByGUID(0, takeGuid)

	local retval, name = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', "", false)
	local track = reaper.GetMediaItemInfo_Value(item, 'P_TRACK')

	-- now acquire the name of the parent track, as well as it's color
	local retval, trackName = reaper.GetTrackName(track)
	local color = reaper.GetTrackColor(track)

	table.insert(bookmarks, Button:Create(nil, nil, 'bookmark', trackName, name, take, item, track, itemGuid, takeGuid, 150, 25, "", color))

	local groups = {}
	local i = 1

	while savedgroups ~= '' do
		if savedgroups:find(',') then
			local s, e = savedgroups:find(',')
			local t = savedgroups:sub(1, s - 1)
			if t then
				table.insert(bookmarks[#bookmarks].groups, tonumber(t))
			end
			savedgroups = savedgroups:sub(e + 1)
		end
		
		i = i + 1
	end
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
