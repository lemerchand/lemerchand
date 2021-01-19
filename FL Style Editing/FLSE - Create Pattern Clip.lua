reaper.ClearConsole()

function dbg(text, p)
	if p == true then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(text))
end

reaper.Undo_BeginBlock()


if reaper.CountMediaItems(0) < 1 then return end

-----------------------------------
--[		 Create Folder Track 	]--
-----------------------------------
function create_parent(tracks)
	
	local parentName = 'New SEQ Track'

	-- Find where to create, and insert
	local index = tracks[#tracks].id
	reaper.InsertTrackAtIndex(index, true)

	-- Get the track, name it
	local tr = reaper.GetTrack(0, index)
	reaper.GetSetMediaTrackInfo_String( tr, 'P_NAME', parentName, true )

	-- Return it's index and userdata
	return {id=index, tr=reaper.GetTrack(0, index)}
end

-----------------------------------
--[		Move Selected Tracks	]--
-----------------------------------
function move_tracks_to_parent(parent)
	
	reaper.ReorderSelectedTracks(parent.id+1, 1)

end

function assign_name(parent)
	local itemCount = reaper.CountMediaItems(0)
	local patternCount = 0

	for i = 0, itemCount - 1 do
		local take = reaper.GetActiveTake(reaper.GetMediaItem(0, i))
		local ret, takeName = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', '', false)

		if takeName then if takeName:find('Pattern') then patternCount = patternCount + 1 end end
	end

	local parentTake = reaper.GetActiveTake(parent.item)
	reaper.GetSetMediaItemTakeInfo_String(parentTake, 'P_NAME', 'Pattern ' .. patternCount + 1 , true)

end

-----------------------------------
--[		Create Parent Item		]--
-----------------------------------

function insert_parent_item(parent)
	-- Set time selection to selected items
	reaper.Main_OnCommand(40290, 0)
	reaper.SetOnlyTrackSelected(parent.tr)
	-- Insert and item
	reaper.Main_OnCommand(40214, 0)
	parent.item = reaper.GetSelectedMediaItem(0, 0)

end


function restore_OG_selected_tracks(tracks)
	local trackCount = reaper.CountTracks(0)
	for i, track in ipairs(tracks) do
		reaper.SetTrackSelected(track.tr, true)
	end
end

function colorize_tracks(parent)
	reaper.SetTrackSelected(parent.tr, true)
	-- Set parent track to the color of it's first child
	reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_COLTRACKNEXT'), 0)
	-- Set all tracks in family to this color
	reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_COLCHILDREN'), 0)
end

function group_items()

	-- Select all items in selections
	reaper.Main_OnCommand(40717, 0)
	-- Group Items
	reaper.Main_OnCommand(40032, 0)
end

-----------------------------------
--[			   Main				]--
--[								]--
-----------------------------------
function main()

	reaper.PreventUIRefresh(1)

	local parent = false
	local isParent = false
	local tracks = {}

	-- Unselect all tracks
	reaper.Main_OnCommand(40297, 0)

	-- [1] Select tracks with selected items
	-- [2] Determine their folder depth
	--     Sort between parent or tracks
	-- [3a] Store parent data or [3b] Create  a parent
	local itemCount = reaper.CountSelectedMediaItems(0)
	for i = 0, itemCount -1 do
		

		-- Get and select item's track
		local track = reaper.GetMediaItemInfo_Value(
				reaper.GetSelectedMediaItem(0,i), 'P_TRACK')
		reaper.SetTrackSelected(track, true)									-- [1]
	
		-- Evaluate family
		local parentCheck = reaper.GetParentTrack(track) 
		if parentCheck then
			local parentID = reaper.GetMediaTrackInfo_Value(parentCheck, 'IP_TRACKNUMBER', '',  false) -1
			parent = {id=parentID , tr=parentCheck}
		else
			table.insert(tracks, {id=reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER', '',  false) -1, tr=track})
		end

	end

	if not parent then
		parent = create_parent(tracks)
	end

	insert_parent_item(parent)
	restore_OG_selected_tracks(tracks)	
	reaper.SetTrackSelected(parent.tr, false)
	move_tracks_to_parent(parent)
	colorize_tracks(parent)
	
	assign_name(parent)
	group_items()

	reaper.PreventUIRefresh(-1)
end

-----------------------------------
main()
reaper.Undo_EndBlock('Create Pattern Clip', -1)