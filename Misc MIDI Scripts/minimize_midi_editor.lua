function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('../libss/cf.lua')
reaper.ClearConsole()


local btn_add = Button:Create(nil, 10, " ADD", nil, nil,nil,nil, 40, 35)
local btn_clear = Button:Create(nil, btn_add.y+btn_add.h+5, " CLR", nil, nil, nil, nil, 40, 35)
local bookmarks = {}
local clickTimer = -1
local debug = false
local dockstate = 0


function load_global_settings()
	local file = io.open(script_path .. "globalsettings.dat", 'r')

	if not file then save_global_settings() ;  file = io.open(script_path .. "globalsettings.dat", 'r') end

	local line
	
	io.input(file)

	while true do
		line = file:read()
		if line == nil then break end
		if line:find("dockstate=") then dockstate = line:sub(line:find("=")+1) end
	end
	file:close()
end

function save_global_settings()
	local file = io.open(script_path .. "globalsettings.dat", 'w')
	local line
	
	io.output(file)

	file:write('dockstate=' .. gfx.dock(-1))
	file:close()

end

function new_bookmark()
	local context = reaper.MIDIEditor_GetActive() or -1
	local selectedItems = 1
	local take, item

	-- if there is no currently active ME then we need to look for selected arrangeview items
	if context == -1 then selectedItems =  reaper.CountSelectedMediaItems(0) end

	-- run thrugh the selected items
	for i = 0, selectedItems-1 do
		-- if we are looking for items then...
		if context == -1 then 
			item = reaper.GetSelectedMediaItem(0, i)
			take = reaper.GetActiveTake(item)
		-- if we are looking for ME then...
		else
			take = reaper.MIDIEditor_GetTake(context) 
			item = reaper.GetMediaItemTake_Item(take)
		end

		-- either way, we need a track name, and a track object
		local retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( take, 'P_NAME', "", false)
		local track = reaper.GetMediaItemInfo_Value( item, 'P_TRACK' )

		-- now let's check for and prevent duplicate bookmarks
		for ii, b in ipairs(bookmarks) do
			if b.item == item then goto pass end
		end

		-- now acquire the name of the parent track, as well as it's color
		local retval, trackName = reaper.GetTrackName( track )
		local color = reaper.GetTrackColor( track )


		-- create the button for it, add it into bookmarks, don't worrk about the x/y since we
		-- will run update_button_position() anyway. 
		table.insert(bookmarks, Button:Create(nil, nil, trackName:sub(1,20), stringNeedBig:sub(1,20), editor, take, item, 150, 35, color))
		update_button_position()
		
		-- in case it's a duplicate, go on to the next item
		::pass::
	end
end



function update_button_position()
--[[	
		So now we need to run thruogh the table of book marks and move their positions relative to 
		one aother and the dimensions of the gfx window

 		1. If we are on the first bookmark then set the x/y manully (this accounts for the add/clr btns..
 			all subsequent bookmarks cabn be positioned relative to that
		2. Place them to the right of the previouse btn..if they exceed the window's edge then reset their X
			and increase their y (relative to the buttons above) 
]]--
	for i, b in ipairs(bookmarks) do
		if not bookmarks[i-1] then 						--[1]
			b.x = 55
			b.y = 10
		else 											--[2]
			b.x = bookmarks[i-1].x + 155			
			b.y = bookmarks[i-1].y
			if b.x+b.w >= gfx.w-10 then
				b.x = 55
				b.y = bookmarks[i-1].y + 40
			end
		end
	end
end

function prev_editor()

	for i, me in ipairs(bookmarks) do	
		if me.active then 
			if i == 1 then 
				group_exec(bookmarks, 'false')
				bookmarks[#bookmarks]:restore_ME()
				return
			else
				group_exec(bookmarks, 'false')
				bookmarks[i-1]:restore_ME()
				return
			end
		end
	end
	bookmarks[1]:restore_ME()
end

function next_editor()
	for i, me in ipairs(bookmarks) do	
		if me.active then 
			if i == #bookmarks then 
				group_exec(bookmarks, 'false')
				bookmarks[1]:restore_ME()
				return
			else
				group_exec(bookmarks, 'false')
				bookmarks[i+1]:restore_ME()
				return
			end
		end
	end	
	bookmarks[1]:restore_ME()

end

function clear_all_bookmarks(closeWindow)
	for i = #bookmarks, 1, -1 do
		table.remove(Elements, i+2)
	end
	bookmarks = {}
	update_button_position()
	if closeWindow then reaper.Main_OnCommand(40716, 0) end
end


--[[

	Load settings, create window, look at a pig's butt

]]--

load_global_settings()

gfx.init("MIDI Editor Tray", 225,500, dockstate)




function main()

	
	--Draws all elements
	fill_background()
	draw_elements()

	--let's find our alt+tab keys (actually alt-ctrl-left/right)
	-- 37 = < 39 = >

	if reaper.JS_Mouse_GetState(-1) == 20 and clickTimer < 0 then
		if reaper.JS_VKeys_GetState(-1):byte(37) == 1 then 
			prev_editor() 
			clickTimer = 1
		elseif reaper.JS_VKeys_GetState(-1):byte(39)  == 1 then 
			next_editor() 
			clickTimer = 1
		elseif reaper.JS_VKeys_GetState(-1):byte(13) == 1 then new_bookmark()
		elseif reaper.JS_VKeys_GetState(-1):byte(8) == 1 then clear_all_bookmarks(true)
		end

	end

	-- Creates a bookmark
	if btn_add.leftClick then 
		new_bookmark()
	end

	-- Clear all bookmarks
	if btn_clear.leftClick then
		clear_all_bookmarks(false)
	elseif btn_clear.rightClick then
		clear_all_bookmarks(true)

	end

	for i, b in ipairs(bookmarks) do
		if b.lastClick == 1 and b.mouseUp then 
			local window, segment, details = reaper.BR_GetMouseCursorContext()
			if segment == "track" then 
				reaper.SelectAllMediaItems(0, false)
				reaper.SetMediaItemSelected(b.item, true)
				reaper.Main_OnCommand(40057, 0)
				reaper.Main_OnCommand(42398, 0)
				b.lastClick = 0
			else b:restore_ME() end 
				b.lastClick = 0
		end
		if b.rightClick and clickTimer  < 0 then 
			table.remove(bookmarks, i)
			--WARNING: The i+1 is to help lua find the button. If there is no button before the bookmarks begin then remove +2
			table.remove(Elements, i+2)
			update_button_position()
			clickTimer = 5
		end

	end

	-- This hack prevents accidental clearing from one mouse click
	if clickTimer ~= -1 then clickTimer = clickTimer - 1 end

	local char = gfx.getchar()
	--Exit/defer handling
	if char == 27  then 
		save_global_settings()
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	elseif char == 26 and gfx.mouse_cap == 12 then reaper.Main_OnCommand(40030, 0)
	elseif char == 26 then reaper.Main_OnCommand(40029, 0)

	-- Otherwise keep window open
	end
	reaper.defer(main)
	
-- DEBUG

debug = false
if debug then
	cons("Bookmark count: " .. #bookmarks .. "\n")
	for i, b in ipairs(bookmarks) do
		cons(i .. ". " .. b.txt .. "\n" .. '\nlastclick: ' .. b.lastClick)
	end
	debug = false
end

end
main()