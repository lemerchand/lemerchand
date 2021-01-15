-- @version 0.661b
-- @author Lemerchand
-- @provides
--    [main] .
--    [nomain] cf.lua
--    [nomain] ui.lua
--    [nomain] vf.lua
--    [nomain] imgs/*.png
-- @changelog
--    + Shift-click to view multiple pins
--    + Only one error when items not found on load
--    + Fixed midi to audio trigger
--    + Script now looks for alternate items
--    + Added Birdbird's midi-to-audio trigger

local scriptName = "Item Tray"
local versionNumber = ' 0.661b'
local projectPath = reaper.GetProjectPath(0)
function reaperDoFile(file) local info = debug.getinfo(1, 'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('cf.lua')
reaperDoFile('vf.lua')

reaper.ClearConsole()
toolTipTime = 20

--Frames
local frm_controls = Frame:Create(5, -13, nil, nil, '', 'main')
local frm_groups = Frame:Create(5, -13, nil, nil, "", 'main')
local frm_settings = Frame:Create(5, -13, nil, nil, '', 'settings', true)

-----------------------------------
--[ MAINVIEW]--
-----------------------------------

local btn_add = Button:Create(
	nil, nil, 'control', "", nil, nil, nil, nil, nil, nil, 40, 25, '', nil, '/imgs/pin.png', 11)
btn_add.id = 'add'
btn_add.help = 'Pin selected items to tray\nHotkey: Ctrl+Alt+Enter\n\nRight-Click to add all items'

local btn_clear = Button:Create(
	nil, nil, 'control', "", nil, nil, nil, nil, nil, nil, 40, 25, '', nil, '/imgs/clear.png', 12)
btn_clear.id = 'clear'
btn_clear.help = 'Clear all pins.\n\nRight-click to clear all pins \nand close all midi editors'

local btn_closeMEWs = Button:Create(
	nil, nil, 'control', "", nil, nil, nil, nil, nil, nil, 40, 25, '', nil, '/imgs/exit.png', 13)
btn_closeMEWs.id = 'closeMEWS'
btn_closeMEWs.help = 'Close all midi editors\nHotkey: Ctrl+Alt+Backspace'

local tgl_settings = Toggle:Create(
	nil, nil, 'ui', '', false, 40, 25, nil, '/imgs/gears.png')
tgl_settings.help = 'Settings'
tgl_settings.id = 'tglsettings'

local search = TextField:Create(
	nil, nil, 150, 22, "", false, false)

local page = Page:Create(
	nil, nil, 150, nil, 'control', 1)
page.id = 'pagecontrol'
page.help = 'Pages contain groups.\n\nRight-click for more options'

local btn_add_group = Button:Create(
	nil, nil, 'control', '+', nil, nil, nil, nil, nil, nil, 
	20, 20, 'Adds a group to \norganize pinned items\n\nRight-click a group \nfor more options')
btn_add_group.id = 'addgroup'


local btn_prev_page = Button:Create(
	nil, nil, 'control', "<", nil, nil, nil, nil, nil, nil, 20, 20, 'Previous Page')
btn_prev_page.id = 'prevpage'

local btn_next_page = Button:Create(
	nil, nil, 'control', " >", nil, nil, nil, nil, nil, nil, 20, 20)

local btn_add_page = Button:Create(
	nil, nil, 'control', ' +', nil, nil, nil, nil, nil, nil, 20, 20, 'Adds a page to organize groups', nil)
btn_add_page.id = 'addpage'


-----------------------------------
--[ Settings]--
-----------------------------------
local tgl_tooltips = Toggle:Create(nil, nil, 'settings', "Show Tooltips")
tgl_tooltips.id = 'tgltooltips'
tgl_tooltips.help = 'Enable/disable tooltips'
tgl_tooltips.hide = true

tip = Tooltip:Create(nil, nil, nil, toolTipTime, {.1, .1, .1}, {.92, .92, .68})
tip.btype = 'all'

bookmarks = {}
groups = {}

local clickTimer = -1
local UIRefresh = 10

---------------------
-- Global Settings --
---------------------
local dockstate = 0
local windowxpos, windowypos, windowHeight, windowWidth
enableHelp = true

function load_project_settings()
	local line
	local errors = 0
	local file = io.open(projectPath .. 'bm.dat', 'r')
	io.input(file)
	
	if not file then return end
	
	page.pages.names = {}
	
	while true do
		
		line = file:read()
		if not line then break end
		
		if line:find('page=') then page:Add(line:sub(line:find('=') + 1)) end
		if line:find('groupname=') then
			local page = file:read()
			add_group(tonumber(page:sub(page:find('=') + 1)), line:sub(line:find('=') + 1))
		end
		
		if line:find('bookmark=') then
			
			local itemGuid = line:sub(line:find('=') + 1)
			local takeGuid = file:read()
			local savedgroups = file:read()
			if savedgroups:find('bmgroup=') then
				savedgroups = savedgroups:sub(savedgroups:find('=') + 1)
			end
			
			if pcall(load_bookmark, itemGuid, takeGuid, savedgroups) then else
				errors = errors + 1
			end
			
		end
		if errors > 0 then
			reaper.MB('Some Bookmarks could not be restored.\nThey may have been deleted since the previous run.', 'Somethin\'s amiss', 0)
		end
	end
	file:close()
	
end

function save_project_settings()
	local file = io.open(projectPath .. 'bm.dat', 'w')
	io.output(file)
	
	for p, page in ipairs(page.pages.names) do
		file:write('page=' .. page .. '\n')
	end
	
	for g, group in ipairs(groups) do
		file:write('groupname=' .. group.txt .. '\n' .. 'grouppages=' .. group.page .. '\n')
	end
	
	for b, bookmark in ipairs(bookmarks) do
		file:write(
		'bookmark=' .. bookmark.itemGuid .. '\n' .. bookmark.takeGuid .. '\n')
		file:write('bmgroup=')
		for g, group in ipairs(bookmark.groups) do
			file:write(group .. ',')
		end
		file:write('\n')
	end
	
	file:close()
end

function load_global_settings()
	local file = io.open(script_path .. "globalsettings.dat", 'r')
	
	if not file then
		windowHeight = 500
		windowWidth = 300
		
		return
		-- save_global_settings()
		-- file = io.open(script_path .. "globalsettings.dat", 'r')
	end
	
	local line
	
	io.input(file)
	
	while true do
		line = file:read()
		if line == nil then break end
		if line:find("dockstate=") then dockstate = line:sub(line:find("=") + 1) end
		if line:find('enableHelp=') then
			enableHelp = line:sub(line:find("=") + 1)
			if enableHelp == 'true' then enableHelp = true else enableHelp = false end
		end
		if line:find('windowheight=') then windowHeight = line:sub(line:find("=") + 1) end
		if line:find('windowwidth=') then windowWidth = line:sub(line:find("=") + 1) end
	end
	file:close()
end

function save_global_settings()
	local file = io.open(script_path .. "globalsettings.dat", 'w')
	local line
	
	io.output(file)
	
	file:write('dockstate=' .. gfx.dock(-1) .. '\n')
	file:write('enableHelp=' .. tostring(enableHelp) .. '\n')
	file:write('windowwidth=' .. gfx.w.. '\n')
	file:write('windowheight=' .. gfx.h.. '\n')
	file:close()
	
end

function add_group(p, name)
	local retval
	if not name then
		retval, name = reaper.GetUserInputs("Group Name", 1, 'Group Name:', 'Name')
		if not retval then return end
	end
	table.insert(groups, Toggle:Create(nil, nil, 'group', name, false, 150, 25, p))

end

function check_group_drop(b)
	for i, g in ipairs(groups) do
		
		if hovering(g.x, g.y, g.w, g.h) and b.btype == 'bookmark' then
			g.block = true
			
			if b.mouseUp then
				g.block = false
				table.insert(b.groups, i)

				return true
			end
		end
	end
end

function display_groups(vertical)

	local first = true
	local visible = {}
	
	for i, b in ipairs(groups) do
		b.hide = true
		b.x = -666
		if b.page == page.page then
			
			b.hide = false
			table.insert(visible, b)
			
		else

		end
	end
	
	for i, b in ipairs(visible) do
		if first then
			
			if not vertical then
				b.x = btn_add_group.x
				b.y = btn_add_group.y + btn_add_group.h + 5
				first = false
			else
				b.x = frm_groups.x + 5
				b.y = frm_groups.y + 42
				first = false
			end
		else
			if not vertical then
				
				b.x = visible[i - 1].x + 155
				b.y = visible[i - 1].y
				if b.x + b.w >= frm_groups.x + frm_groups.w - 3 then
					b.x = frm_groups.x + 5
					b.y = visible[i - 1].y + 26
				end
			else
				b.x = visible[i - 1].x + 155
				b.y = visible[i - 1].y
				if b.x + b.w >= frm_groups.x + frm_groups.w - 3 then
					b.x = btn_add.x
					b.y = visible[i - 1].y + 26
				end
			end
		end
	end

end

function display_items(vertical)

	local visible = {}
	local groupsSelected = 0
	for k, g in ipairs(groups) do
		if g.state then
			groupsSelected = groupsSelected + 1
			for b, bookmark in ipairs(bookmarks) do
				bookmark.hide = true
				for i, group in ipairs(bookmark.groups) do
					if group == k then bookmark.hide = false
						for t, present in ipairs(visible) do
							if bookmark == present then goto pass end
						end
						table.insert(visible, bookmark)
						::pass::
					end
				end
			end
		end
	end

	if #visible < 1 and groupsSelected == 0 then visible = bookmarks end

	for i, b in ipairs(visible) do
		b.hide = false
		if not visible[i - 1] then --[1]
			if not vertical then
				b.w = 150
				b.x = frm_groups.x + frm_groups.w + 5
				b.y = 3
			else
				b.w = 160
				if b.x+b.w+150 > gfx.w-7 or not visible[i+1] then
					b.w = gfx.w-20
				else b.w = 160
				end
				b.x = 10
				b.y = frm_groups.y + frm_groups.h + 25
			end
		else
			if not vertical then
				--[2]
				b.w = 150
				b.x = visible[i - 1].x + 150
				b.y = visible[i - 1].y
				if b.x + b.w >= gfx.w - 7 then
					b.x = frm_groups.w + frm_groups.x + 5
					b.y = visible[i - 1].y + 26
				end
			else
				b.w = visible[1].w
				b.x = visible[i - 1].x + 165
				b.y = visible[i - 1].y
				if b.x + b.w >= gfx.w - 7 then
					b.x = btn_add.x
					b.y = visible[i - 1].y + 26
				
				end
			end
		end
	end

end

function new_bookmark()
	
	local context = reaper.MIDIEditor_GetActive() or - 1
	local selectedItems = 1
	local take, item
	
	-- if there is no currently active ME then we need to look for selected arrangeview items
	if context == -1 then selectedItems = reaper.CountSelectedMediaItems(0) end
	
	-- run thrugh the selected items
	for i = 0, selectedItems - 1 do
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
		local retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', "", false)
		local track = reaper.GetMediaItemInfo_Value(item, 'P_TRACK')
		
		-- now let's check for and prevent duplicate bookmarks
		for ii, b in ipairs(bookmarks) do
			if b.item == item then goto pass end
			
		end
		
		-- now acquire the name of the parent track, as well as it's color
		local retval, trackName = reaper.GetTrackName(track)
		local color = reaper.GetTrackColor(track)
		local itemGuid = reaper.BR_GetMediaItemGUID(item)
		local takeGuid = reaper.BR_GetMediaItemTakeGUID(take)
		
		-- create the button for it, add it into bookmarks, don't worrk about the x/y since we
		-- will run update_ui() anyway.
		table.insert(bookmarks, Button:Create(nil, nil, 'bookmark', trackName, stringNeedBig, take, item, track, itemGuid, takeGuid, 150, 25, "", color))
		update_ui()
		
		-- in case it's a duplicate, go on to the next item
		::pass::
	end
end

function update_ui()
	--[[
So now we need to run thruogh the table of book marks and move their positions relative to 
one aother and the dimensions of the gfx window
 
 1. If we are on the first bookmark then set the x/y manully (this accounts for the add/clr btns..
 all subsequent bookmarks cabn be positioned relative to that
2. Place them to the right of the previouse btn..if they exceed the window's edge then reset their X
and increase their y (relative to the buttons above) 
]]--
	
	local vertical
	if gfx.w < gfx.h then vertical = true else vertical = false end
	
	if vertical then

		
		frm_settings.x = 5
		frm_settings.w = gfx.w - 10
		frm_settings.h = 300
		

		frm_controls.w = gfx.w - 10
		frm_controls.h = 70
		
		frm_groups.x = 5
		frm_groups.y = frm_controls.y + frm_controls.h + 5
		frm_groups.w = gfx.w - 10
		frm_groups.h = 185
		
		btn_add.x = frm_controls.x + 5
		btn_add.y = frm_controls.y + 22
		btn_clear.x = btn_add.x + btn_add.w + 5
		btn_clear.y = btn_add.y
		btn_closeMEWs.x = btn_clear.x + btn_clear.w + 5
		btn_clear.y = btn_add.y

		search.x = frm_controls.x + 7
		search.y = btn_add.y + btn_add.h + 5
		search.w = frm_controls.w - 12

		tgl_settings.x = frm_controls.x + frm_controls.w - 45
		tgl_settings.y = btn_add.y
		

	else
		
		frm_controls.w = 207
		frm_controls.h = gfx.h - 7
		
		frm_groups.x = frm_controls.x + frm_controls.w + 5
		frm_groups.w = 315
		frm_groups.h = gfx.h - 7
		frm_groups.y = -13
		btn_add.x = frm_controls.x + 5
		btn_add.y = frm_controls.y + 22
		btn_clear.x = btn_add.x + btn_add.w + 5
		btn_clear.y = btn_add.y
		btn_closeMEWs.x = btn_clear.x + btn_clear.w + 5
		btn_closeMEWs.y = btn_add.y

		frm_settings.x = tgl_settings.x + tgl_settings.w - 45
		frm_settings.w = 500
		frm_settings.h = gfx.h - 7
		
		search.x = frm_controls.x + 7
		search.y = btn_add.y + btn_add.h + 5
		search.w = frm_controls.w - 12

		
		tgl_settings.x = frm_controls.x + frm_controls.w - 45
		tgl_settings.y = btn_add.y
	end
	
	btn_add_group.x = frm_groups.x + 5
	btn_add_group.y = frm_groups.y + 21
	btn_prev_page.x = btn_add_group.x + btn_add_group.w
	btn_prev_page.y = btn_add_group.y
	
	btn_add_page.x = frm_groups.x + frm_groups.w - 25
	btn_add_page.y = btn_prev_page.y
	
	btn_next_page.x = btn_add_page.x - 20
	btn_next_page.y = btn_prev_page.y
	
	page.x = frm_groups.x
	page.w = frm_groups.w
	page.y = btn_add_group.y + 6
	
	-- Place groups
	
	for c, g in ipairs(groups) do
		g.hide = true
	end
	
	display_groups(vertical)
	display_items(vertical)
	
end

function prev_editor()
	for i, me in ipairs(bookmarks) do
		if me.active then
			if i == 1 then

				bookmarks[#bookmarks]:restore_ME()
				return
			else
				bookmarks[i - 1]:restore_ME()
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

				bookmarks[1]:restore_ME()
				return
			else

				bookmarks[i + 1]:restore_ME()
				return
			end
		end
	end
	bookmarks[1]:restore_ME()
	
end

function close_all_MEWS()
	local retval, openMEWS = pcall(get_open_MEWS)
	for m, mew in ipairs(openMEWS) do
		reaper.MIDIEditor_OnCommand(mew, 2)
	end
end

function onexit ()
	save_project_settings()
	save_global_settings()
	reaper.JS_Window_SetFocus(last_window)
end

-----------------------------------
--[  LOAD SETTINGS]--
--[And create window ]--
-----------------------------------

load_global_settings()
load_project_settings()

if enableHelp then tgl_tooltips.state = true else tgl_tooltips.state = false end

gfx.init(scriptName .. versionNumber, windowWidth, windowHeight, dockstate, 100, 100)
-- Keep on top
local win = reaper.JS_Window_Find(scriptName .. versionNumber, true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

update_ui()

function main()
	
	--Draws all elements
	fill_background()
	draw_elements()
	
	-----------------------------------
	--[ Intercepted Hot Keys    ]--
	-----------------------------------
	
	if reaper.JS_Mouse_GetState(-1) == 20 and clickTimer < 0 then
		if reaper.JS_VKeys_GetState(-1):byte(37) == 1 then
			prev_editor()
			clickTimer = 1
		elseif reaper.JS_VKeys_GetState(-1):byte(39) == 1 then
			next_editor()
			clickTimer = 1
		elseif reaper.JS_VKeys_GetState(-1):byte(13) == 1 then new_bookmark()
		elseif reaper.JS_VKeys_GetState(-1):byte(8) == 1 then close_all_MEWS()
		elseif reaper.JS_VKeys_GetState(-1):byte(32) == 1 then db('Current Page: ' .. page.page, page)

		end
		
	end
	
	-----------------------------------
	--[Main Panel]--
	-----------------------------------
	
	if search.leftClick then search.active = true end
	
	-- Creates a bookmark
	if btn_add.leftClick then

		new_bookmark()
		update_ui()
	elseif btn_add.rightClick then
		reaper.SelectAllMediaItems(0, true)
		new_bookmark()
		update_ui()
	end
	
	-- Clear all bookmarks
	if btn_clear.leftClick then
		clear_all_bookmarks(false)
	elseif btn_clear.rightClick then
		clear_all_bookmarks(true)
		update_ui()
	end

	-- Closde Editors button
	if btn_closeMEWs.leftClick then
		close_all_MEWS()
	end
	
	-- Settings
	if tgl_settings.leftClick then

		if tgl_settings.state == false then
			for e, element in ipairs(Elements) do
				if element.btype == 'settings' then
					element.hide = true
				else
					element.hide = false
				end
			end

		end

	end

	-----------------------------------
	--[Page Panel]--
	-----------------------------------
	
	-- Group Add button
	if btn_add_group.leftClick then
		add_group(page.page)
		update_ui()
	end
	
	-- Page Add button
	
	if btn_add_page.leftClick then
		page:Add()
		update_ui()
	end
	
	if page.rightClick then
		gfx.x, gfx.y = gfx.mouse_x, gfx.mouse_y
		local option = gfx.showmenu("Add Page|Rename Page||Delete Page|Delete All Pages")
		if option == 1 then page:Add()
		elseif option == 2 then page:Rename()
		elseif option == 3 then page:Remove(false)
		elseif option == 4 then page:Remove(true)
		end
	end
	
	if btn_prev_page.leftClick then
		if page.page - 1 > 0 then
			page.page = page.page - 1
		else
			page.page = #page.pages.names
		end
		update_ui()
	end
	
	if btn_next_page.leftClick then
		if page.page + 1 > #page.pages.names then
			page.page = 1
		else
			page.page = page.page + 1
		end
		update_ui()
	end
	
	-----------------------------------
	--[Bookmarks]--
	-----------------------------------
	
	-- If the user is dragging then disable buttons
	-- TODO: Block all necessary elements
	for i, b in ipairs(bookmarks) do
		if b.leftClick then
			for ii, element in ipairs(Elements) do
				if element.btype == 'control' or element.btype == 'bookmark' then
					element.block = true
				end
			end
		end
		
		-- Shift Left Click to pin to current editor
		if b.shiftLeftClick then
			if b.active then
				reaper.SetMediaItemInfo_Value(b.item, 'B_UISEL', 0)
				reaper.UpdateArrange()
				b.active = false
			else
				reaper.SelectAllMediaItems(0, false)
				reaper.SetMediaItemSelected(b.item, true)
				b.active = true
				for am, bookmark in ipairs(bookmarks) do
					if bookmark.active then
						reaper.SetMediaItemSelected(bookmark.item, true)
					end
				end
				reaper.Main_OnCommand(40153, 0)
			end
		end
		
		-- if the user was dragging a bookmark....
		if b.lastClick == 1 and b.mouseUp then

			
			local itemType
			local window, segment, details = reaper.BR_GetMouseCursorContext()
			
			local ret, itemType = pcall(audio_or_midi, b.take)
			
			if segment == "track" then
				local destination = reaper.BR_GetMouseCursorContext_Item()
				
				if not destination then

					if pcall(Button.Insert, b, 'mouse') then else
						if missing_item(b, i) then end
					end
					b.lastClick = 0
				elseif itemType == 'audio' and reaper.TakeIsMIDI(reaper.GetActiveTake(destination)) then
					
					if pcall(midi_to_audio, b.item, destination) then
						b.lastClick = 0
						
					else
						if missing_item(b, i) then end
						b.lastClick = 0
					end
				else
					
					if pcall(Button.Insert, b, 'mouse') then else
						
						if missing_item(b, i) then end
					end
					b.lastClick = 0
				end
				

				-- if the user click-releases a bookmark...
			else
				
				if not check_group_drop(b) then
					if b.active then
						b.active = false
						reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 2)
					else
						for b, bookmark in ipairs(bookmarks) do
							bookmark.active = false
						end
						if pcall(Button.restore_ME, b) then else
							if missing_item(b, i) then end
						end
					end
				end
				update_ui()
			end
			b.lastClick = 0
		end
		
		if b.ctrlLeftClick and clickTimer < 0 and b.btype == 'bookmark' then
			b:Remove(false, i)
			update_ui()
			clickTimer = 2
		end
		
		if b.rightClick then
			local options = 'Open in Editor|Rename|Insert at Edit Cursor||Remove'
			if #b.groups > 0 then options = options .. '|>Remove from...|All Groups|' end
			for ii, group in ipairs(b.groups) do
				if ii + 1 > #b.groups then options = options .. '|<' .. groups[ii].txt
				else options = options .. '|' .. groups[ii].txt
				end
			end
			gfx.x, gfx.y = gfx.mouse_x, gfx.mouse_y
			local option = gfx.showmenu(options)
			
			if option == 0 then
			elseif option == 1 then
				b:restore_ME()
			elseif option == 2 then

				b:Rename()
				
			elseif option == 3 then
				if pcall(Button.Insert, b, 'edit') then else
					missing_item(b, i)
				end
				
			elseif option == 4 then
				
				b:Remove(false, i)
				
			elseif option == 5 then
				b:RemoveFromGroup(true)
			else
				b:RemoveFromGroup(false, option - 5)
			end
			
		end
		
	end
	
	-----------------------------------
	--[Groups]--
	-----------------------------------
	
	for i, b in ipairs(Elements) do
		if b.btype == 'group' then
			-- Update the UI so it shows the appropriate items
			if b.leftClick then
				update_ui()
				
				-- for display additional group options
			elseif b.rightClick then
				gfx.x, gfx.y = gfx.mouse_x, gfx.mouse_y
				local options = 'Rename Group'
				local pagecount = #page.pages.names
				local pageoptions = {}
				local pageoptions_index = {}
				
				-- if the pagecount is less than 2 then fuck this menu
				-- otherwise, add the pages to a table to parse
				-- that way we can easily give the final option the '|<' flag
				if pagecount > 1 then options = options .. '|>Move to...'
					for p, pagename in ipairs(page.pages.names) do
						if p == page.page then goto pass
						else
							table.insert(pageoptions, pagename)
							table.insert(pageoptions_index, p)

						end
						::pass::
					end
				end
				
				-- Add the potential pages to the options
				for p, pageoption in ipairs(pageoptions) do
					options = options .. '|' .. pageoption
				end
				
				if pagecount > 1 then options = options .. '||<'
				else options = options .. '|' end
				
				-- Add the remaining options
				options = options .. "Send to New Page||Delete Group|Delete all groups"
				local option = gfx.showmenu(options)

				-- Add pagecount-2 to get the right menu item to the right if
				if option == 1 then
					b:Rename()
				elseif option == #pageoptions_index + 2 then
					page:Add()

					b:Move(page.page)
					
				elseif option == #pageoptions_index + 3 then
					b:Remove(false, i)
				elseif option == #pageoptions_index + 4 then
					
					-- confrim deletion
					local confirm = reaper.ShowMessageBox("Delete all groups in all pages?", "Confirm", 4)
					if confirm == 7 then break end
					b:Remove(true)
				elseif option == 0 then
					-- Now that the static options are ruled out...
					-- let's equate the number value to the pageoptions and move the group
					-- the selected option index-1 should  be the right page

				else
					b:Move(pageoptions_index[option - 1])

				end
				update_ui()
			end

		end
	end
	
	-----------------------------------
	--[ Setting Bindings]--
	-----------------------------------
	
	if tgl_tooltips.state then enableHelp = true else enableHelp = false end
	
	-----------------------------------
	--[ Upkeep ]--
	-----------------------------------
	
	-- This hack prevents accidental clearing from one mouse click
	if clickTimer ~= -1 then clickTimer = clickTimer - 1 end
	
	local char = gfx.getchar()
	--Exit/defer handling
	if char == 26 and gfx.mouse_cap == 12 then reaper.Main_OnCommand(40030, 0)
	elseif char == 26 then reaper.Main_OnCommand(40029, 0)
	else
		
	end

	
	if UIRefresh == 0 then
		if gfx.dock(-1) == 1 then UIRefresh = 15 else UIRefresh = 5 end
		update_ui()
	else
		
		UIRefresh = UIRefresh - 1
	end

	if tgl_settings.state == true then
		for e, element in ipairs(Elements) do
			if element.btype == 'settings'
				or element.btype == 'ui' then element.hide = false
			else
				if element.btype == 'all' then else element.hide = true end
			end
		end
	end

	reaper.defer(main)
	if enableHelp then tip:Draw() end
end
main()
reaper.atexit(onexit)
