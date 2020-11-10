if reaper.CountSelectedMediaItems(0) == 0 then return end

local item = reaper.GetSelectedMediaItem(0, 0)
local track = reaper.GetMediaTrackInfo_Value( reaper.GetMediaItem_Track(item), 'P_PARTRACK' )

reaper.Main_OnCommand(40421, 0)
reaper.Main_OnCommand(40376, 0)