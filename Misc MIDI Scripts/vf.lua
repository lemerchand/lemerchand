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

function add_group(p)
	local retval, name = reaper.GetUserInputs( "Group Name", 1, 'Group Name:', 'Name' )	
	table.insert(p, Toggle:Create(nil, nil, 'group', name, false, 150, 25 ))
end

function check_group_drop()

	for i, g in ipairs(page.pages.groups[page.page]) do
		if hovering(g.x, g.y, g.w, g.h) then
			table.insert(page.pages.groups[page.page], g)
			return true
		end
	end

end

function display_groups(vertical)

	for i, b in ipairs(page.pages.groups[page.page]) do
			
			b.hide = false
			if not page.pages.groups[page.page][i-1] then 						
				if not vertical then 
					b.x = btn_add_group.x
					b.y = btn_add_group.y+btn_add_group.h+5
				else
					b.x = frm_groups.x+5
					b.y = frm_groups.y + 40

				end
			else 	
				if not vertical then 
														
					b.x = page.pages.groups[page.page][i-1].x + 155			
					b.y = page.pages.groups[page.page][i-1].y
					if b.x+b.w >= frm_groups.x+frm_groups.w-3 then
						b.x = frm_groups.x + 5
						b.y =  page.pages.groups[page.page][i-1].y + 26
					end
				else
					b.x = page.pages.groups[page.page][i-1].x + 155			
					b.y = page.pages.groups[page.page][i-1].y
					if b.x+b.w >= frm_groups.x+frm_groups.w-3 then
						b.x = btn_add.x
						b.y = page.pages.groups[page.page][i-1].y + 26
					end
				end
			end
		
		
	end
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
			-- TODO: add a setting to show multiple takes with same name
			--if b.name == stringNeedBig then goto pass end
		end

		-- now acquire the name of the parent track, as well as it's color
		local retval, trackName = reaper.GetTrackName( track )
		local color = reaper.GetTrackColor( track )


		-- create the button for it, add it into bookmarks, don't worrk about the x/y since we
		-- will run update_ui() anyway. 
		table.insert(bookmarks, Button:Create(nil, nil, 'bookmark', trackName, stringNeedBig, take, item, track, 150, 25, color))
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
		frm_controls.w = gfx.w-10
		frm_controls.h = 70

		frm_groups.x = 5
		frm_groups.y = frm_controls.y+frm_controls.h+5
		frm_groups.w = gfx.w-10
		frm_groups.h = 185

		btn_add.x = frm_controls.x+5
		btn_add.y = frm_controls.y+22
		btn_clear.x = btn_add.x+btn_add.w+5
		btn_clear.y = btn_add.y

		search.x=frm_controls.x+7
		search.y=btn_add.y+btn_add.h+5
		search.w = frm_controls.w-12
	else
		frm_controls.w = 207
		frm_controls.h = gfx.h-7

		frm_groups.x = frm_controls.x+frm_controls.w+5
		frm_groups.w = 315
		frm_groups.h = gfx.h-7
		frm_groups.y = -13
		btn_add.x = frm_controls.x+5
		btn_add.y = frm_controls.y+22
		btn_clear.x = btn_add.x+btn_add.w+5
		btn_clear.y = btn_add.y

		search.x=frm_controls.x+7
		search.y=btn_add.y+btn_add.h+5
		search.w = frm_controls.w-12
	end

	btn_add_group.x = frm_groups.x+5
	btn_add_group.y = frm_groups.y+20
	btn_prev_page.x = btn_add_group.x+btn_add_group.w+5
	btn_prev_page.y = btn_add_group.y

	page.x = btn_prev_page.x+btn_prev_page.w+5
	page.y = btn_add_group.y+6

	btn_next_page.x = page.x+page.w+5
	btn_next_page.y = btn_prev_page.y

	btn_add_page.x = btn_next_page.x+btn_next_page.w+5
	btn_add_page.y = btn_prev_page.y

-- Place groups
	
	for c, g in ipairs(page.pages.groups) do
		for cc, gg in ipairs(g) do
			gg.hide = true
		end
	end

	display_groups(vertical)

-- Place bookmarks
	for i, b in ipairs(bookmarks) do
		if not bookmarks[i-1] then 						--[1]
			if not vertical then 
				b.x = frm_groups.x+frm_groups.w+5
				b.y = 3
			else
				b.x = 10
				b.y = frm_groups.y+frm_groups.h + 25
			end
		else 	
			if not vertical then 
													--[2]
				b.x = bookmarks[i-1].x + 155			
				b.y = bookmarks[i-1].y
				if b.x+b.w >= gfx.w-7 then
					b.x = frm_groups.w+frm_groups.x + 5
					b.y = bookmarks[i-1].y + 26
				end
			else
				b.x = bookmarks[i-1].x + 155			
				b.y = bookmarks[i-1].y
				if b.x+b.w >= gfx.w-7 then
					b.x = btn_add.x
					b.y = bookmarks[i-1].y + 26
				end
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

	for e = #Elements, 1, -1 do
		
		if Elements[e].btype == "bookmark" then table.remove(Elements, e) end
	end
	bookmarks = {}
	update_ui()
	if closeWindow then reaper.Main_OnCommand(40716, 0) end
end


function onexit ()
	
	save_global_settings()
	reaper.JS_Window_SetFocus(last_window)
end
