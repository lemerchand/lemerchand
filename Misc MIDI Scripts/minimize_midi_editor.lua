function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('../libss/cf.lua')
reaper.ClearConsole()

gfx.init("MIDI Editor Tray", 225,500, true)

local btn_add = Button:Create(nil, 10, "Add", nil, nil,nil,nil, nil, 35)
local btn_clear = Button:Create(nil, btn_add.y+btn_add.h+5, "CLR", nil, nil, nil, nil, nil, 35)
local bookmarks = {}
local clickTimer = -1


function new_bookmark()
	local context = reaper.MIDIEditor_GetActive() or -1
	local selectedItems = 1
	local take, item

	if context == -1 then selectedItems =  reaper.CountSelectedMediaItems(0) end


	for i = 0, selectedItems-1 do
		if context == -1 then 
			item = reaper.GetSelectedMediaItem(0, i)
			take = reaper.GetActiveTake(item)
		else
			take = reaper.MIDIEditor_GetTake(context) 
			item = reaper.GetMediaItemTake_Item(take)
		end
		
		local retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( take, 'P_NAME', "", false)
		local track = reaper.GetMediaItemInfo_Value( item, 'P_TRACK' )
		for ii, b in ipairs(bookmarks) do
			if b.item == item then goto pass end
		end
		local retval, trackName = reaper.GetTrackName( track )
		local color = reaper.GetTrackColor( track )


		table.insert(bookmarks, Button:Create(nil, nil, trackName:sub(1,20), stringNeedBig:sub(1,20), editor, take, item, 150, 35, color))
		update_button_position()
		::pass::
	end
end



function update_button_position()
	for i, b in ipairs(bookmarks) do
	
		if not bookmarks[i-1] then
			b.x = 55
			b.y = 10
		else
			b.x = bookmarks[i-1].x + 155
			b.y = bookmarks[i-1].y
			if b.x+b.w >= gfx.w-10 then
				b.x = 55
				b.y = bookmarks[i-1].y + 40
			end
		end

	end
end



function main()
	--Draws all elements
	fill_background()
	draw_elements()

	if btn_add.leftClick then 
		new_bookmark()
	end
	if btn_clear.leftClick then
		for i = #bookmarks, 1, -1 do
			table.remove(Elements, i+2)
		end
		bookmarks = {}
		update_button_position()
	end

	for i, b in ipairs(bookmarks) do
		if b.leftClick then b:restore_ME() end
		if b.rightClick and clickTimer  < 0 then 
			table.remove(bookmarks, i)
			--WARNING: The i+1 is to help lua find the button. If there is no button before the bookmarks begin then remove +2
			table.remove(Elements, i+2)
			update_button_position()
			clickTimer = 5
		end
	end

	if clickTimer ~= -1 then clickTimer = clickTimer - 1 end

	local char = gfx.getchar()
	--Exit/defer handling
	if char == 27  then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else reaper.defer(main)
	end
end
main()