-- @version 0.5.1
-- @author Lemerchand
-- @about FL Studio-style Editing Suite - Make Pattern Clip unique. Bind to hotkey or toolbar.
-- @provides
--    [main] .
-- @changelog
--    + None - this is the first release.

function assign_name(item)
	local itemCount = reaper.CountMediaItems(0)
	local patternCount = 0

	for i = 0, itemCount - 1 do
		local take = reaper.GetActiveTake(reaper.GetMediaItem(0, i))
		local ret, takeName = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', '', false)

		if takeName then 
			if takeName:find('Pattern') then 
				patternCount = patternCount + 1 
			end 
		end
	end

	local parentTake = reaper.GetActiveTake(item)
	reaper.GetSetMediaItemTakeInfo_String(parentTake, 'P_NAME', 'Pattern ' .. patternCount , true)

end

local itemCount = reaper.CountSelectedMediaItems(0)
for i = 0, itemCount - 1 do
	local item = reaper.GetSelectedMediaItem(0, i)
	local take = reaper.GetActiveTake(item)
	local takeName = reaper.GetTakeName(take)
	
	if takeName:find('Pattern') then
		assign_name(item)
		-- Select all grouped items
		reaper.Main_OnCommand(40034, 0)
		-- Remove from pool
		reaper.Main_OnCommand(41613, 0)
	end
end

