--All elements get loaded into this table to make drawing and reseting easier
Elements = {}

--Call this with Elements to quickly draw all elements
function draw_elements()
	for e, element in ipairs(Elements) do
		element:Draw()
	end
end

--Fills the gfx window background with color
function fill_background()
	local r, g, b, a = .19, .19, .19, 1
	local w, h = gfx.w, gfx.h

	gfx.set(r, g, b, a)
	gfx.rect(0, 0, w, h, true)

end

--Returns true if mouse is hovering over
function hovering(x, y, w, h)
	if gfx.mouse_x >= x and gfx.mouse_x <= x + w and gfx.mouse_y >= y and gfx.mouse_y <= y + h then return true end
	return false
end

--Draws an empty rectangle
function draw_border(x, y, w, h, r, g, b, fill)

	local r = r or .45
	local g = g or .45
	local b = b or .45
	gfx.set(r, g, b, 1)
	gfx.rect(x, y, w, h, fill)
end

--Draws a filled round rectangle
function filled_round_rect(x, y, w, h, r, g, b)

	-- local r = r or .7
	-- local g = g or .7
	-- local b = b or .7

	--Draw plain filled in rectangle
	gfx.x, gfx.y = x, y
	--gfx.set(r, g, b, 1)

	gfx.rect(x + 1, y + 1, w - 1, h - 1, true)

	--Round off the corners
	gfx.set(.19, .19, .19, 1)
	gfx.roundrect(x, y, w, h, 4, true)

end

--Performs various functions on multiple elements in a group
function group_exec(group, action)

	local action = string.lower(action)
	if action == 'draw' then
		for e, element in ipairs(group) do
			element:Draw()
		end
	elseif action == 'reset' then
		for e, element in ipairs(group) do
			element:Reset()
		end
	elseif action == 'hide' then
		for e, element in ipairs(group) do
			element.hide = true
		end
	elseif action == 'show' then
		for e, element in ipairs(group) do
			element.hide = false
		end
	elseif action == 'false' then
		for e, element in ipairs(group) do
			element.active = false
		end
	elseif action == 'block' then
		for e, element in ipairs(group) do
			element.block = true
		end
	elseif action == 'unblock' then
		for e, element in ipairs(group) do
			element.block = false
		end

	end
end

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: BUTTON---------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Button = {}
Button.__index = Button

function Button:Create(x, y, btype, txt, name, take, item, track, itemGuid, takeGuid, w, h, help, color, font, fontSize, hide)

	if font == nil then gfx.setfont(16, "Lucida Console", 11, 'b') end

	if w == nil then
		ww, hh = gfx.measurestr(txt)
		w = ww + 19
	end

	if h == nil then
		ww, hh = gfx.measurestr(txt)
		h = hh + 17
	end

	local this = {
		x = x or 10,
		y = y or 10,
		btype = btype or nil,
		txt = txt or "Button",
		name = name or nil,
		take = take or nil,
		item = item or nil,
		track = track or nil,
		w = w or 30,
		h = h or 30,
		help = help or "",
		color = color or nil,
		mouseOver = false,
		mouseDown = false,
		leftClick = false,
		rightClick = false,
		middleClick = false,
		ctrlLeftClick = false,
		ctrlRightClick = false,
		shiftLeftClick = false,
		shiftRightClick = false,
		altLeftClick = false,
		altRightClick = false,
		hide = hide or false,
		font = "Lucida Console",
		fontSize = fontSize or 11,
		active = false,
		mouseUp = true,
		block = false,
		groups = {},
		itemGuid = itemGuid or nil,
		takeGuid = takeGuid or nil
	}
	setmetatable(this, Button)
	table.insert(Elements, this)
	return this
end

function Button:ResetClicks()

	self.leftClick = false
	self.rightClick = false
	self.middleClick = false
	self.ctrlLeftClick = false
	self.ctrlRightClick = false
	self.shiftLeftClick = false
	self.shiftRightClick = false
	self.altLeftClick = false
	self.altRightClick = false

end

function Button:Draw()

	self:ResetClicks()
	if self.hide then return end
	local drag = false
	local r, g, b = .3, .3, .3

	if self.color then
		r, g, b = reaper.ColorFromNative(self.color)
		r = r / 255
		g = g / 255
		b = b / 255
	end

	if r <= .05 and g <= .05 and b <= .05 then
		r = .23
		g = .23
		b = .23
	end

	gfx.setfont(16, self.font, self.fontSize, 'b')

	--filled_round_rect(self.x-1, self.y-1, self.w+1, self.h+1,r,g,b)
	gfx.x, gfx.y = self.x, self.y

	if self.mouseDown == true then

		gfx.set(r - .3, g - .3, b - .3, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, true)

	elseif self.mouseOver then

		gfx.set(r + .1, g + .1, b + .1, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, true)

	elseif self.mouseOver == false then

		gfx.set(r - .05, g - .05, b - .05, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2)
	end

	if self.active then
		gfx.set(r + .15, g + .15, b + .15)
		gfx.rect(self.x + 2, self.y + self.h - 3, self.w - 3, 2)
	end

	-- Some color mngmt I may decide to use later
	-- if r > g and r > b then r = r -.05 ; b = b+.1
	-- elseif g > r and g > b then g = g - .05 ; b=b+.1
	-- elseif b > r and b > g then b = b - .05 ; r = r +.1
	-- end

	if r + g + b > 1.8 then
		gfx.set(.25, .25, .25)

	else gfx.set(.7, .7, .7)
	end

	--if (r <= .3 and g <= .3 and b <= .3) or not self.color then gfx.set(.7,.7,.7) else gfx.set(r-.3, g-.3, b-.3) end

	if self.name then
		-- gfx.x, gfx.y = self.x, self.y-self.fontSize
		-- gfx.drawstr(self.txt, 1 | 4, self.w+self.x, self.h+self.y)
		gfx.x, gfx.y = self.x - 3, self.y + 3 --+ self.fontSize + (self.fontSize * .5)
		gfx.drawstr(self.name:sub(1, 20), 1 | 4, self.w + self.x, self.h + self.y)
	else
		gfx.x = self.x - 5
		gfx.drawstr(self.txt, 1 | 4, self.w + self.x, self.h + self.y + 3)
	end

	
	if hovering(self.x, self.y, self.w, self.h) and not self.block then

		if not self.tt and enableHelp then
			--local mx, my = reaper.GetMousePosition()
			--reaper.TrackCtl_SetToolTip(self.help, mx + 20, my + 20, true)
			self.tt = true
		end
		
		self.mouseOver = true
		if gfx.mouse_cap >= 1 and self.mouseDown == false then

			if gfx.mouse_cap == 4 or gfx.mouse_cap == 8 or gfx.mouse_cap == 16 then self.mouse_down = false
			else
				self.mouseDown = true
				if gfx.mouse_cap == 1 then self.leftClick = true; self.mouseUp = false
				elseif gfx.mouse_cap == 2 then self.rightClick = true
				elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
				elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true; self.mouseUp = false
				elseif gfx.mouse_cap == 10 then self.shiftRightClick = true
				elseif gfx.mouse_cap == 17 then self.altLeftClick = true
				elseif gfx.mouse_cap == 18 then self.altRightClick = true
				elseif gfx.mouse_cap == 64 then self.middleClick = true

				end
				self.lastClick = gfx.mouse_cap
			end
		elseif gfx.mouse_cap == 0 and self.mouseDown == true then
			self.mouseDown = false
			self.mouseUp = true
		end
	else
		self.mouseOver = false
		if self.tt then
			reaper.TrackCtl_SetToolTip('', self.x + self.w + 20, self.y + self.h, true)
			self.tt = false
		end
		if self.mouseDown and gfx.mouse_cap ~= 0 then
			--User is dragging

			reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(182))
		elseif gfx.mouse_cap == 0 then

			self.block = false
			self.mouseDown = false
			self.mouseUp = true

		end
	end
end

function Button:Reset()

end

function Button:restore_ME()
	--TODO: Store and restore selected media items
	local starttime = reaper.GetMediaItemInfo_Value(self.item, 'D_POSITION')
	reaper.SelectAllMediaItems(0, false)
	reaper.SetEditCurPos(starttime, true, true)
	reaper.SetMediaItemSelected(self.item, true)
	if reaper.TakeIsMIDI(self.take)	then 
		reaper.Main_OnCommand(40153, 0)
	else
		reaper.Main_OnCommand(41589, 0)
	end
	self.active = true
end


function Button:Rename()
	local retval, takeName = reaper.GetUserInputs("Item Name", 1, 'Item Name:', self.name)
	if not retval then return end

	self.name = takeName
	reaper.GetSetMediaItemTakeInfo_String( self.take, 'P_NAME', takeName, true )
end

function Button:Insert(location)
	reaper.SelectAllMediaItems(0, false)
	reaper.SetMediaItemSelected(self.item, true)

	reaper.Main_OnCommand(40057, 0)
	
	if location == 'mouse' then
		reaper.Main_OnCommand(41221, 0)
	elseif location == 'edit' then
		reaper.Main_OnCommand(42398, 0)
	end
end

function Button:RemoveFromGroup(all, group)

	if all then self.groups = {} 
	else
		table.remove(self.groups, group)
	end

end




-------------------------------------------END: BUTTON--------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: TEXT FIELD-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

TextField = {}
TextField.__index = TextField

function TextField:Create(x, y, w, h, txt, active, multiline, fontSize, r, g, b, font, hide)

	if font == nil then gfx.setfont(1, "Lucida Console", 13) end

	if w == nil then
		ww, hh = gfx.measurestr(txt)
		w = ww + 19
	end

	if h == nil then
		ww, hh = gfx.measurestr(txt)
		h = hh + 15
	end

	local this = {
		x = x or 10,
		y = y or 10,
		btype = 'control',
		w = w,
		h = h,
		txt = txt or "Some text.",
		fontSize = fontSize or 12,
		r = r or .7,
		g = g or .7,
		b = b or .7,
		font = font or "Lucida Console",
		hide = hide or false,
		active = active or false,
		hover = false,
		multiline = multiline or false,
		alwaysActive = false,
		returned = false,
		cpos = 0,
		blink = 0,
		image = script_path .. 'search.png'

	}

	setmetatable(this, TextField)
	table.insert(Elements, this)

	gfx.loadimg(1, script_path .. 'search.png')

	return this
end

function TextField:Draw()
	self:ResetClicks()
	if self.hide then return end

	draw_border(self.x, self.y, self.w, self.h)
	draw_border(self.x + 1, self.y + 1, self.w - 2, self.h - 2, .22, .22, .22, true)

	gfx.x, gfx.y = self.x + 5, self.y + 5
	gfx.set(self.r, self.g, self.b, 1)
	gfx.setfont(1, self.font, self.fontSize)

	local txtlen = string.len(self.txt)
	local charwidth = gfx.measurestr("-")

	gfx.x = self.x + self.w - 22
	gfx.blit(1, .43, 0)

	if self.active and self.blink <= 15 then
		gfx.x = self.x + 5 + (self.cpos * charwidth)
		gfx.y = self.y + 10
		gfx.drawstr("-")
		self.blink = self.blink + 1
	elseif self.active and self.blink <= 30 then
		gfx.x = self.x + 10 + (self.cpos * charwidth)
		gfx.drawstr(" ")
		self.blink = self.blink + 1
	else
		gfx.x = self.x + 10 + (self.cpos * charwidth)
		gfx.drawstr("")
		self.blink = 1
	end

	gfx.x, gfx.y = self.x + 5, self.y + 5
	gfx.drawstr(self.txt)

	if hovering(self.x, self.y, self.w, self.h) then

		self.hover = true
		if gfx.mouse_cap == 1 then self.leftClick = true
		elseif gfx.mouse_cap == 2 then self.rightClick = true
		elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
		elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
		elseif gfx.mouse_cap == 10 then self.shiftRightClick = true
		elseif gfx.mouse_cap == 17 then self.altLeftClick = true
		elseif gfx.mouse_cap == 18 then self.altRightClick = true
		elseif gfx.mouse_cap == 64 then self.middleClick = true
		end

	else
		self.hover = false
		if gfx.mouse_cap == 1 or gfx.mouse_cap == 2 then self.active = false end
	end

end

function TextField:Change(char)
	gfx.setfont(3, self.font, self.fontSize)

	if self.txt == "" then self.cpos = 0 end

	if self.active and char == 1919379572 and self.cpos < string.len(self.txt) then
		self.cpos = self. cpos + 1
	elseif self.active and char == 1818584692 and self.cpos >= 1 then
		self.cpos = self.cpos - 1
	elseif self.active and char == 6647396 then self.cpos = string.len(self.txt)
	elseif self.active and char == 1752132965 then self.cpos = 0
	end

	if self.active and gfx.measurestr(self.txt) + self.x <= self.w - 10 then
		if char >= 33 and char <= 126 then

			self.txt = self.txt:sub(1, self.cpos) .. string.char(char) .. self.txt:sub(self.cpos + 1)

			--self.txt = self.txt .. string.char(char)
			self.cpos = self.cpos + 1
		elseif char == 32 then
			self.txt = self.txt:sub(1, self.cpos) .. " " .. self.txt:sub(self.cpos + 1)
			self.cpos = self.cpos + 1
		end
	end

	if self.active and char == 8 then
		self.txt = self.txt:sub(1, self.cpos - 1) .. self.txt:sub(self.cpos + 1)
		self.cpos = self.cpos - 1
	elseif self.active and char == 6579564 then
		self.txt = self.txt:sub(1, self.cpos) .. self.txt:sub(self.cpos + 2)
	elseif self.active and char == 13 then
		if self.multiline then self.txt = self.txt .. "\n"
		else
			self.returned = true
			if not self.alwaysActive then self.active = false end
		end
		self.cpos = 0
	end
end

function TextField:ResetClicks()

	self.leftClick = false
	self.rightClick = false
	self.middleClick = false
	self.ctrlLeftClick = false
	self.ctrlRightClick = false
	self.shiftLeftClick = false
	self.shiftRightClick = false
	self.altLeftClick = false
	self.altRightClick = false

end

function TextField:Reset()

end

------------------------------------END: TEXT FIELD------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: FRAME----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Frame = {}
Frame.__index = Frame

function Frame:Create(x, y, w, h, title, font, fontSize, r, g, b, hide)

	local this = {
		x = x or 10,
		y = y or 10,
		w = w or 100,
		h = h or 100,
		btype = 'ui',
		title = title or "Some text.",
		font = font or "Lucida Console",
		fontSize = fontSize or 14,
		r = r or .4,
		g = g or .4,
		b = b or .4,
		hide = hide or false,
	tabs = {}}

	setmetatable(this, Frame)
	table.insert(Elements, this)
	return this
end

function Frame:Draw()

	if self.hide then return end

	gfx.setfont(2, self.font, self.fontSize)
	local titleWidth, titleHeight = gfx.measurestr(self.title)

	--Draw title
	gfx.set(.8, .25, .3)
	gfx.x, gfx.y = self.x + 3, self.y + 3
	gfx.drawstr(self.title)

	--Draw tabs

	--Draw attatched tabs
	for t, tab in ipairs(self.tabs) do
		tab:Draw(self.tabs)
	end

	--Draw frame
	gfx.set(self.r, self.g, self.b)
	gfx.roundrect(self.x, self.y + 17, self.w, self.h, 4, true)
	gfx.roundrect(self.x + 1, self.y + 18, self.w - 2, self.h - 2, true)

end

function Frame:AttatchTab(tab)
	--Binds a tabgroup to the frame

	--Measure frame title
	gfx.setfont(2, self.font, self.fontSize)
	tw, th = gfx.measurestr(self.title)
	--Make a counter to add the total width of all tabs
	local totalTabLength = tw + self.x + 20

	--Add the width of each tab title to the counter
	gfx.setfont(3, tab.font, tab.fontSize)
	for t, tt in ipairs(self.tabs) do
		w, h = gfx.measurestr(tt.name)
		totalTabLength = totalTabLength + w + 10
	end
	--Bind the tab to the frame's tab table
	table.insert(self.tabs, tab)
	tab.x = totalTabLength
	tab.y = self.y + 2
	tab.w, tab.h = gfx.measurestr(tab.name)

end

function Frame:Reset()

end
----------------------------------------------end framw---------------

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: TABS-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Tabs = {}
Tabs.__index = Tabs

function Tabs:AddTab(name, selected, help)
	local this = {
		name = name or "Tab",
		x = 0,
		y = 0,
		w = 0,
		h = 0,
		selected = selected or false,
		help = help or "",
		font = font or "Lucida Console",
		fontSize = fontSize or 11,
		r = r or .7,
		g = g or .7,
		b = b or .7,
	elements = {}}
	setmetatable(this, Tabs)

	return this
end

function Tabs:Draw(tabGroup)

	gfx.x, gfx.y = self.x, self.y
	local w, h = gfx.measurestr(self.name)

	if self.selected then --dDraw a line under the currently selected tab title
		gfx.set(.2, .8, .25)
		gfx.line(self.x, self.y + 11, self.x + self.w, self.y + 11)
		group_exec(self.elements, 'show') --Show only contents in this tabGroup
	else
		group_exec(self.elements, 'hide') --Hide others
	end

	gfx.setfont(3, self.font, self.fontSize)
	gfx.set(self.r, self.g, self.b)
	gfx.drawstr(self.name)

	if hovering(self.x, self.y, self.w, self.h) then
		status:Display(self.help)

		if gfx.mouse_cap == 1 then

			Tabs:Reset(tabGroup)--Hide all tab grouped elements
			self.selected = true --Show only the selected tab's elements
		end
	end

end

function Tabs:AttatchElements(elements)
	--Use this to bind elements to a tab

	for e, element in ipairs(elements) do
		table.insert(self.elements, element)
	end
end

function Tabs:Reset(tabGroup)
	--Sets all tabs to unselected so their bound elements are hidden
	for t, tab in ipairs(tabGroup) do
		tab.selected = false
	end
end

--------------------------------------------------------------------------------------------------------------
-------------------------------------------CLASS: TOGGLE------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Toggle = {}
Toggle.__index = Toggle

function Toggle:Create(x, y, btype, txt, state, w, h, page, hide)

	if font == nil then gfx.setfont(15, "Lucida Console", 11) end

	if w == nil then
		ww, hh = gfx.measurestr(txt)
		w = ww + 13
	end

	if h == nil then
		ww, hh = gfx.measurestr(txt)
		h = hh + 13
	end

	local this = {
		x = x or 10,
		y = y or 10,
		btype = btype or nil,
		txt = txt or "X",
		w = w or 25,
		h = h or 25,
		mouseOver = false,
		mouseDown = false,
		state = state or false,
		default = state or false,
		leftClick = false,
		rightClick = false,
		middleClick = false,
		ctrlLeftClick = false,
		ctrlRightClick = false,
		shiftLeftClick = false,
		shiftRightClick = false,
		altLeftClick = false,
		altRightClick = false,
		hide = hide or false,
		font = "Lucida Console",
		fontSize = fontSize or 11,
		block = false,
		page = page or nil,
		clickTemp = nil
	}
	setmetatable(this, Toggle)
	table.insert(Elements, this)
	return this
end

function Toggle:ResetClicks()
	self.mouseUp = false
	self.leftClick = false
	self.rightClick = false
	self.middleClick = false
	self.ctrlLeftClick = false
	self.ctrlRightClick = false
	self.shiftLeftClick = false
	self.shiftRightClick = false
	self.altLeftClick = false
	self.altRightClick = false

end

function Toggle:Reset()
	self.state = self.default
end

function Toggle:Draw()

	self:ResetClicks()
	if self.hide then return end

	gfx.setfont(15, self.font, self.fontSize, 'b')

	--draw_border(self.x, self.y, self.w, self.h)
	gfx.x, gfx.y = self.x, self.y

	if self.mouseDown then
		gfx.set(.24, .24, .24, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2)

	elseif self.state == true and self.mouseOver == false then

		gfx.set(.5, .26, .36, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2)

	elseif self.state == true and self.mouseOver then

		gfx.set(.55, .31, .41, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2)

	elseif self.mouseOver and self.state == false then

		gfx.set(.31, .31, .31, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, true)

	elseif self.mouseOver == false then

		gfx.set(.27, .27, .27, 1)
		filled_round_rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, true)

	end

	gfx.set(.7, .7, .7, 1)
	gfx.drawstr(self.txt, 1 | 4, self.w + self.x, self.h + self.y + 2)

	if self.block == false and hovering(self.x, self.y, self.w, self.h) then
		self.mouseOver = true

		if gfx.mouse_cap >= 1 and self.mouseDown == false then

			self.mouseDown = true
			self.clickTemp = gfx.mouse_cap

		elseif gfx.mouse_cap == 1 and self.mouseDown == true then

		elseif gfx.mouse_cap == 0 and self.mouseDown == true then

			if self.clickTemp == 1 then 
				self.leftClick = true
				if self.state == true then self.state = false else self.state = true end
			elseif self.clickTemp == 2 then self.rightClick = true
			elseif self.clickTemp == 5 then self.ctrlLeftClick = true
			elseif self.clickTemp == 9 then self.shiftLeftClick = true
			elseif self.clickTemp == 10 then self.shiftRightClick = true
			elseif self.clickTemp == 17 then self.altLeftClick = true
			elseif self.clickTemp == 18 then self.altRightClick = true
			elseif self.clickTemp == 64 then self.middleClick = true
			end

			self.mouseDown = false
			self.mouseUp = true
		end
	else
		self.mouseOver = false
		self.mouseDown = false
	end
end


function Toggle:Remove(all, group)


	if all then
		for e = #Elements, 1, -1 do
			if Elements[e].btype == 'group' then 
				for ee, bm in ipairs(bookmarks) do
					bm.groups = {}

				end
				table.remove(Elements, e) 
			end
		end
		groups = {}
		

	else
		
		for k, g in ipairs(groups) do
			if g == self then 
				for b, bookmark in ipairs(bookmarks) do
					for bb, bg in ipairs(bookmark.groups) do
						if bg == k then
							table.remove(bookmark.groups, k)
						end
					end
				end
				table.remove(groups, k)
			end
		end					

		table.remove(Elements, group)
	end
end

function Toggle:Rename()
	local retval, groupname = reaper.GetUserInputs("Group Name", 1, 'New Name:', self.txt)
	if not retval then return end
	self.txt = groupname
end

function Toggle:Move(p)

	self.page = p

end

------------------------------------------END: TOGGLE---------------------------------------------------------

Page = {}
Page.__index = Page

function Page:Create(x, y, w, h, btype, page, cx, cy)

	if font == nil then gfx.setfont(15, "Lucida Console", 13) end

	if w == nil then
		ww, hh = gfx.measurestr(page)
		w = ww + 13
	end

	if h == nil then
		ww, hh = gfx.measurestr(page)
		h = hh + 13
	end

	local this = {
		x = x or 10,
		y = y or 10,
		btype = btype or nil,
		page = page or 1,
		w = w or 25,
		h = h or 25,
		mouseOver = false,
		mouseDown = false,
		leftClick = false,
		rightClick = false,
		hide = hide or false,
		font = "Lucida Console",
		fontSize = fontSize or 13,
		block = false,
		pages = {names = {'Pages'}},
	groups = {}}
	setmetatable(this, Page)
	table.insert(Elements, this)
	return this
end

function Page:Draw()

	self:Reset_Clicks()
	gfx.set(.16, .16, .16)
	gfx.rect(self.x + 30, self.y - 3, self.w - 57, self.h - 10, true)
	gfx.set(.7, .7, .7)
	gfx.x, gfx.y = self.x, self.y
	gfx.drawstr(self.pages.names[self.page], 1, self.w + self.x, self.h + self.y)

	if hovering(self.x + 50, self.y - 3, self.w - 100, self.h - 12) then
		if gfx.mouse_cap == 1 then self.leftClick = true
		elseif gfx.mouse_cap == 2 then self.rightClick = true
		end
	end
end

function Page:Add(name)


	local pagename, retval
	if not name then 
		retval, pagename = reaper.GetUserInputs("Page Name", 1, 'Page Name:', 'Name')
		if not retval then return end
	else
		pagename = name
	end

	table.insert(self.pages.names, pagename)
	self.page = #self.pages.names
	
end


function Page:Reset_Clicks()
	self.leftClick = false
	self.rightClick = false
end

function Page:Rename()
	local retval, pagename = reaper.GetUserInputs("Page Name", 1, 'New Name:', self.pages.names[self.page])
	if not retval then return end
	self.pages.names[self.page] = pagename
end

function Page:Remove(all)

	if all then
		self.pages.names = {'Pages'}
		self.page = 1

	else
		if #self.pages == 1 then 
			self.pages.names[1] = "Pages"
		else
			table.remove(self.pages.names, self.page)
			self.page = self.page - 1
		end
	end

end

