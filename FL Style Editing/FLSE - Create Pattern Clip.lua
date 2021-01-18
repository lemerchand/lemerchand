reaper.ClearConsole()

function dbg(text, p)
	if p == true then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(text))
end

reaper.Undo_BeginBlock()



-----------------------------------
--[		 Create Folder Track 	]--
-----------------------------------
function create_parent(tracks)
	-- TODO: Al Gore Rhythm to determine Pattern name
	local parentName = 'Pattern'

	-- Find where to create, and insert
	local index = tracks[1].id
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


-----------------------------------
--[		Create Parent Item		]--
-----------------------------------

function insert_parent_item(parent)
	-- Set time selection to selected items
	reaper.Main_OnCommand(40290, 0)
	reaper.SetOnlyTrackSelected(parent.tr)
	-- Insert and item
	reaper.Main_OnCommand(40214, 0)

	-- Set name
	parentItem = reaper.GetSelectedMediaItem(0, 0)
	parentItemTake = reaper.GetActiveTake(parentItem)
	reaper.GetSetMediaItemTakeInfo_String(parentItemTake, 'P_NAME', '[SEQ] Pattern', true)
end


function restore_OG_selected_tracks(tracks)
	local trackCount = reaper.CountTracks(0)
	for i, track in ipairs(tracks) do
		reaper.SetTrackSelected(track.tr, true)
	end
end


-----------------------------------
--[			   Main				]--
--[								]--
-----------------------------------
function main()

	reaper.PreventUIRefresh(1)

	local parent
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

		-- Evaluate folder status
		local depth = reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH')	-- [2]
		if depth == 0 then 
			isParent = false 
			local trackID = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER') - 1
			table.insert(tracks, {id=trackID, tr=track})
		elseif depth == 1 then 
			isParent = true 
		end

		-- If we find a parent, let's store it's data
		-- Let's unselect it and it's items, and move
		-- the desired tracks under it's caring wing
		if isParent then 
			local parentID = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER') - 1
			parent = {id=parentID, tr=track} 											-- [3]
		end
	end

	-- If not parent is found, create one and move
	-- the desired track under it
	if not parent then 															-- [3b]
		parent = create_parent(tracks)
		insert_parent_item(parent)
	end

	restore_OG_selected_tracks(tracks)	
	reaper.SetTrackSelected(parent.tr, false)
	move_tracks_to_parent(parent)
	
	reaper.PreventUIRefresh(-1)
end

-----------------------------------
main()
reaper.Undo_EndBlock('Create Pattern Clip', -1)