function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('../libss/cf.lua')
reaper.ClearConsole()

gfx.init("MIDI Editor Tray", 200,50, true)

local btn_add = Button:Create(nil, 10, "Add", nil, nil,nil,nil, nil, 35)
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
			if b.item == item then return end
		end
		local retval, trackName = reaper.GetTrackName( track )
		local color = reaper.GetTrackColor( track )

		table.insert(bookmarks, Button:Create((#bookmarks*155)+10 + 55, nil, trackName:sub(1,20), stringNeedBig:sub(1,20), editor, take, item, 150, 35))
	end
end

function restore_ME(editor, item)
	reaper.SelectAllMediaItems(0, false)
	reaper.SetMediaItemSelected( item, true )
	reaper.Main_OnCommand(40153, 0)
end


function update_button_position()
	for i, b in ipairs(bookmarks) do
		b.x = (i * 155 - 155) + 65
	end
end



function main()
	--Draws all elements
	fill_background()
	draw_elements()

	if btn_add.leftClick then 
		new_bookmark()
	end

	for i, b in ipairs(bookmarks) do
		if b.leftClick then restore_ME(b.editor, b.item) end
		if b.rightClick and clickTimer  < 0 then 
			table.remove(bookmarks, i)
			--WARNING: The i+1 is to help lua find the button. If there is no button before the bookmarks begin then remove +1
			table.remove(Elements, i+1)
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