-- @version .5
-- @author Lemerchand
-- @about FL Studio-style Editing Suite - Toggle Patterns. Bind to Item Double-click Mouse Modifier
-- @provides
--    [main] .
-- @changelog
--    + None - this is the first release.

reaper.Undo_BeginBlock()

function toggle_pattern(item, take)
	local parent = reaper.GetMediaItemInfo_Value(item, 'P_TRACK')
	local state = reaper.GetMediaTrackInfo_Value(parent, 'I_FOLDERCOMPACT')

	-- if the Folder is 
	if state == 0 or state == 1 then 
		-- Collapse folder
		reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_COLLAPSE'), 0)
		-- zoom out project
		reaper.Main_OnCommand(40295, 0)
		-- Decrease Track size
		reaper.SetMediaTrackInfo_Value(parent, 'I_HEIGHTOVERRIDE', 86)
	else
		-- Open folder
		reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_UNCOLLAPSE'), 0)
		-- Select all items in group
		reaper.Main_OnCommand(40034, 0)
		-- Zoom to slection
		reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_ITEMZOOM'), 0)

		-- Modify track heights
		reaper.SetMediaTrackInfo_Value(parent, 'I_HEIGHTOVERRIDE', 86)
		local trackCount = reaper.CountTracks(0)
		for i = 0, trackCount - 1 do
			local track = reaper.GetTrack(0, i)
			reaper.SetMediaTrackInfo_Value(track, 'I_HEIGHTOVERRIDE', 86)
		end
	end




end

function main()
	reaper.PreventUIRefresh(1)
	-- Find the item the user is dbl-clicking
	local mx, my = reaper.GetMousePosition()
	local item = reaper.GetItemFromPoint(mx, my, true)
	local take = reaper.GetActiveTake(item)
	
	-- Go ahead and grab the name because...
	local ret, takeName = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', '', false)
	
	-- If the take is midi we can bypass a lot of work (see audio/video shit below)
	-- If the take is midi then check to see if our pattern flag is present...
	if reaper.TakeIsMIDI(take) then 
		if takeName:find('Pattern') then
			toggle_pattern(item, take)
		
		-- if it isn't then go about bizness as normal
		else
			-- Open item(s) in midi editor
			reaper.Main_OnCommand(40153, 0)
		end

	-- But if it isn't let's see what sort of file it is. Chances are
	-- We can just open the item properties pane.
	-- TODO: Figure out how to deal with subprojects!
	else 
		local pe = reaper.GetMediaItemTake_Source(take)
		local takeFN = reaper.GetMediaSourceFileName( pe, '' )
		local ext = takeFN:sub(-4)

		-- If audio
		if ext == '.wav' or ext == '.ogg'
			or ext == '.mp3'or ext == 'flac' 
			or ext == 'aiff' or ext == '.mov' 
			or ext == 'mpeg' or ext == '.wmv'
			or ext == '.mp4' or ext == '.avi' then
			
			-- Open the item in the properties pane
			reaper.Main_OnCommand(41589, 0)

		end
	end
	reaper.PreventUIRefresh(-1)
end

main()
-- TODO: If statement for what message is displayed
reaper.Undo_EndBlock('Toggle Pattern Clip', -1)
