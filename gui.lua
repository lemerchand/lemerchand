-------------------------------------------------------------------------
--				
--							GUI Library v1 Rev 2
--
-------------------------------------------------------------------------
-- LAST MODIFIED: 2020.10.27
--
--USAGE:
--		- Read the comments, especially parameters
--		- Skip parameters when defining an object to allow the library to 
--			define them for you.
--
--		- Pass 'nil' if you need to skip a parameter that is inbetween two defined parameters
--			eg., btn = Button:Create(10, 10, "Buttong, nil, 100")
--
--		- Group elements in tables for easier manipulation
--
--		- Many elements have the ability to respond to:
--			- (Ctrl/Alt/Shift) Left Mouse clicks
--			- (Ctrl/Alt/Sh2020.10.25 at 10:21ift) Right Mouse clicks
--			- See the individual element's :Create() if unsure
--
--TODO:
--		+ Make pretty
--		+ Fix dropdown draw issue when dropdown choices overlap another dropdown
--		+ Vertical Sliderr
--

-------------------------------------------------------------------------

new_val = nil

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
	local r, g, b, a = .19,.19,.19, 1
	local w, h = gfx.w, gfx.h

	gfx.set(r,g,b,a)
	gfx.rect(0,0,w,h,true)

end

--Returns true if mouse is hovering over 
function hovering(x,y,w,h)
	if gfx.mouse_x >=x and gfx.mouse_x <=x+w and gfx.mouse_y >= y and gfx.mouse_y <= y+h then return true end
	return false
end

--Draws an empty rectangle
function draw_border(x,y,w,h, r, g, b, fill)
	
	r = r or .45
	g = g or .45
	b = b or .45
	gfx.set(r, g, b, 1)
	gfx.rect(x,y,w,h, fill)
end

--Draws a filled round rectangle
function filled_round_rect(x,y,w,h, r, g, b)

	local r = r or .7
	local g = g or .7
	local b = b or .7

	--Draw plain filled in rectangle
	gfx.x, gfx.y = x, y
	gfx.set(r, g, b, 1)

	gfx.rect(x+1, y+1, w-1 , h-1, true)

	--Round off the corners
	gfx.set(.19,.19,.19,1)
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
			element.state = false
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
		elements = {}
	}
	setmetatable(this, Tabs)
	
	return this
end

function Tabs:Draw(tabGroup)

	gfx.x, gfx.y = self.x, self.y
	local w, h = gfx.measurestr(self.name)
	
	if self.selected then 	--dDraw a line under the currently selected tab title
		gfx.set(.2,.8,.25) 
		gfx.line(self.x, self.y+11, self.x+self.w, self.y+11)
		group_exec(self.elements, 'show') 	--Show only contents in this tabGroup
	else
		group_exec(self.elements, 'hide')	 --Hide others
	end
	
	gfx.setfont(3, self.font, self.fontSize)
	gfx.set(self.r, self.g, self.b) 
	gfx.drawstr(self.name)

	if hovering(self.x, self.y, self.w, self.h) then
		status:Display(self.help)

		if gfx.mouse_cap == 1 then

			Tabs:Reset(tabGroup)	--Hide all tab grouped elements
			self.selected = true 	--Show only the selected tab's elements
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
----------------------------------CLASS: FRAME----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Frame = {}
Frame.__index = Frame

function Frame:Create(x,y,w,h,title,font, fontSize, r, g, b, hide)
	
	local this = {
		x = x or 10,
		y = y or 10,
		w = w or 100,
		h = h or 100,
		title = title or "Some text.",
		font = font or "Lucida Console",
		fontSize = fontSize or 14,
		r = r or .4,
		g = g or .4,
		b = b or .4,
		hide = hide or false,
		tabs = {}
	}

	setmetatable(this, Frame)
	table.insert(Elements, this)
	return this
end

function Frame:Draw()

	if self.hide then return end


	gfx.setfont(2, self.font, self.fontSize)
	local titleWidth, titleHeight = gfx.measurestr(self.title)
	

	--Draw title
	gfx.set(.8,.25,.3)
	gfx.x, gfx.y = self.x+3, self.y
	gfx.drawstr(self.title)
	

	--Draw tabs

	--Draw attatched tabs 
	for t, tab in ipairs(self.tabs) do
		tab:Draw(self.tabs)
	end



	--Draw frame
	gfx.set(self.r, self.g, self.b)
	gfx.roundrect(self.x, self.y+17, self.w, self.h, 4, true)
	gfx.roundrect(self.x+1, self.y+18, self.w-2, self.h-2,true)


end


function Frame:AttatchTab(tab)
	--Binds a tabgroup to the frame

	--Measure frame title
	gfx.setfont(2, self.font, self.fontSize)
	tw, th = gfx.measurestr(self.title)
	--Make a counter to add the total width of all tabs
	local totalTabLength = tw + self.x+20

	
	--Add the width of each tab title to the counter
	gfx.setfont(3, tab.font, tab.fontSize)
	for t, tt in ipairs(self.tabs) do
		w,h = gfx.measurestr(tt.name)
		totalTabLength = totalTabLength + w +10
	end
	--Bind the tab to the frame's tab table
	table.insert(self.tabs, tab)
	tab.x = totalTabLength
	tab.y = self.y+2
	tab.w, tab.h = gfx.measurestr(tab.name)

end

function Frame:Reset()

end

------------------------------------END: FRAME----------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: TEXT FIELD-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


TextField = {}
TextField.__index = TextField

function TextField:Create(x,y, w, h, txt, help, active, multiline, fontSize, r, g, b, font, hide)

	if font == nil then gfx.setfont(1, "Lucida Console", 13) end

	if w == nil then 
		ww,hh = gfx.measurestr(txt)
		w = ww + 19
	end

	if h == nil then 
		ww,hh = gfx.measurestr(txt)
		h = hh + 17
	end

	local this = {
		x = x or 10,
		y = y or 10,
		help = help or "",
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
		returned = false,
		blink = 0

	}

	setmetatable(this, TextField)
	table.insert(Elements, this)
	return this
end

function TextField:Draw()
	self:ResetClicks()
	if self.hide then return end

	draw_border(self.x,self.y, self.w,self.h)
	draw_border(self.x+1, self.y+1,self.w-2,self.h-2, .22,.22,.22, true)

	gfx.x, gfx.y = self.x+5, self.y+5
	gfx.set(self.r, self.g, self.b, 1)
	gfx.setfont(1, self.font, self.fontSize)
	


	if self.active  and self.blink <= 15 then 
		gfx.drawstr(self.txt .. "_")
		self.blink = self.blink + 1
	elseif self.active and  self.blink <=30 then
		gfx.drawstr(self.txt .. " ")
		self.blink = self.blink + 1
	else
		gfx.drawstr(self.txt .. "")
		self.blink = 0
	end



	if hovering(self.x, self.y, self.w, self.h) then
		status:Display(self.help)
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


	if self.active and gfx.measurestr(self.txt) + self.x <= self.w then
		if char >= 33 and char <= 126 then self.txt = self.txt .. string.char(char) 
		elseif char == 32 then self.txt = self.txt .. " "
		end
	end


	if self.active and char == 8 then self.txt = self.txt:sub(1,-2)
	elseif self.active and char == 13 then 
		if self.multiline then self.txt = self.txt .. "\n"
		else
			self.returned = true
			self.active = false
		end
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




------------------------------------END: TEXT FIELD----------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: TEXT-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Text = {}
Text.__index = Text

function Text:Create(x,y, txt, help, fontSize, r, g, b, font, hide, w, h)

	if font == nil then gfx.setfont(1, "Lucida Console", 13) end

	if w == nil then 
		ww,hh = gfx.measurestr(txt)
		w = ww + 19
	end

	if h == nil then 
		ww,hh = gfx.measurestr(txt)
		h = hh + 17
	end

	local this = {
		x = x or 10,
		y = y or 10,
		help = help or "",
		w = w,
		h = h,
		txt = txt or "Some text.",
		fontSize = fontSize or 12,
		r = r or .7,
		g = g or .7,
		b = b or .7,
		font = font or "Lucida Console",
		hide = hide or false

	}

	setmetatable(this, Text)
	table.insert(Elements, this)
	return this
end

function Text:Draw()
	self:ResetClicks()
	if self.hide then return end
	gfx.x, gfx.y = self.x, self.y
	gfx.set(self.r, self.g, self.b, 1)
	gfx.setfont(1, self.font, self.fontSize)
	gfx.drawstr(self.txt)

	if hovering(self.x, self.y, self.w, self.h) then
		status:Display(self.help)
		if gfx.mouse_cap == 1 then self.leftClick = true
			elseif gfx.mouse_cap == 2 then self.rightClick = true
			elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
			elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
			elseif gfx.mouse_cap == 10 then self.shiftRightClick = true	
			elseif gfx.mouse_cap == 17 then self.altLeftClick = true
			elseif gfx.mouse_cap == 18 then self.altRightClick = true
			elseif gfx.mouse_cap == 64 then self.middleClick = true
			
		end
	end

end

function Text:ResetClicks()

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

function Text:Reset()

end
----------------------------------END: TEXT------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: BUTTON---------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Button = {}
Button.__index = Button

function Button:Create(x, y, txt, help, w, h, font, fontSize,hide)

	if font == nil then gfx.setfont(16, "Lucida Console", 12, 'b') end

	if w == nil then 
		ww,hh = gfx.measurestr(txt)
		w = ww + 19
	end

	if h == nil then 
		ww,hh = gfx.measurestr(txt)
		h = hh + 17
	end

	local this = {
		x = x or 10,
		y = y or 10,
		txt = txt or "Button",
		help = help or "",
		w=w or 30,
		h=h or 30,
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
		fontSize = fontSize or 12
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

	gfx.setfont(16, self.font, self.fontSize, 'b')

	draw_border(self.x, self.y, self.w, self.h)
	gfx.x, gfx.y = self.x, self.y

	if self.mouseDown == true then

		gfx.set(.24,.24,.24,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	elseif self.mouseOver then 

		gfx.set(.31,.31,.31,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	elseif self.mouseOver == false then

		gfx.set(.27,.27,.27,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	end

	gfx.set(.7,.7,.7,1)
	gfx.drawstr(self.txt, 1 | 4, self.w+self.x, self.h+self.y+3)

	if hovering(self.x, self.y, self.w, self.h) then 
		status:Display(self.help)
		self.mouseOver = true 
		if gfx.mouse_cap >= 1 and self.mouseDown == false then 
			
			if gfx.mouse_cap == 4 or gfx.mouse_cap == 8 or gfx.mouse_cap == 16 then self.mouse_down = false
			else
				self.mouseDown = true
				if gfx.mouse_cap == 1 then self.leftClick = true
				elseif gfx.mouse_cap == 2 then self.rightClick = true
				elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
				elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
				elseif gfx.mouse_cap == 10 then self.shiftRightClick = true	
				elseif gfx.mouse_cap == 17 then self.altLeftClick = true
				elseif gfx.mouse_cap == 18 then self.altRightClick = true
				elseif gfx.mouse_cap == 64 then self.middleClick = true
				
				end
			end
		elseif gfx.mouse_cap == 0 and self.mouseDown == true then
			self.mouseDown = false
		end
	else
		self.mouseOver = false
		self.mouseDown = false
	end
end

function Button:Reset()

end
-------------------------------------------END: BUTTON--------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-------------------------------------------CLASS: INPUTBOX--------------------------------------------------
--------------------------------------------------------------------------------------------------------------

InputBox = {}
InputBox.__index = InputBox

function InputBox:Create(x,y, default, help, w, h)

	if font == nil then gfx.setfont(15, "Lucida Console", 11) end

	if w == nil then 
		ww,hh = gfx.measurestr(default)
		w = ww + 10
	end

	if h == nil then 
		ww,hh = gfx.measurestr(default)
		h = hh + 10
	end

	local this = {
		x = x or 10,
		y = y or 10,
		value = default or "Text",
		default = default or "Text",
		help = help or "",
		w = w or 20,
		h = h or 20,
		font = font or "Lucida Console",
		fontSize = fontSize or 11,
		leftClick = false,
		rightClick = false,
		middleClick = false,
		ctrlLeftClick = false,
		ctrlRightClick = false,
		shiftLeftClick = false,
		shiftRightClick = false,
		altLeftClick = false,
		altRightClick = false,
		mouseDown = false,
		hide = hide or false,
		block = false
	}
	setmetatable(this, InputBox)
	table.insert(Elements, this)
	return this
end

function InputBox:Draw()
	

	if self.hide then return end 

	self:ResetClicks()
	
	gfx.setfont(15, self.font, self.fontSize)
	gfx.x, gfx.y = self.x, self.y
	gfx.set(.7,.7,.6, 1)
	gfx.rect(self.x, self.y, self.w, self.h, false)
	gfx.set(.25,.25,.25)
	gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	gfx.r, gfx.g, gfx.b = .8,.8,.8
	
	--gfx.x, gfx.y = self.x+4, self.y+2
	gfx.drawstr(self.value, 1 | 4, self.x+self.w, self.y+self.h)

	if hovering(self.x, self.y, self.w, self.h) then 

		status:Display(self.help)
		if gfx.mouse_cap >= 1 and self.mouseDown == false then 
			
			if gfx.mouse_cap == 4 or gfx.mouse_cap == 8 or gfx.mouse_cap == 16 then self.mouse_down = false
			else
				self.mouseDown = true
				if gfx.mouse_cap == 1 then 
					retval, retvals_csv, v = reaper.GetUserInputs( "Enter a value", 1, "", self.default)
					self.value = string.upper(retvals_csv)
				elseif gfx.mouse_cap == 2 then self.rightClick = true
				elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
				elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
				elseif gfx.mouse_cap == 10 then self.shiftRightClick = true	
				elseif gfx.mouse_cap == 17 then self.altLeftClick = true
				elseif gfx.mouse_cap == 18 then self.altRightClick = true
				elseif gfx.mouse_cap == 64 then self.middleClick = true
				
				end
			end
		elseif gfx.mouse_cap == 0 and self.mouseDown == true then
			self.mouseDown = false
		end
	else
		self.mouseDown = false
	end


end

function InputBox:Reset()
	self.value = self.default
end

function InputBox:ResetClicks()

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


------------------------------------------END: USER INPUT-----------------------------------------------------


--------------------------------------------------------------------------------------------------------------
-------------------------------------------CLASS: TOGGLE------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Toggle = {}
Toggle.__index = Toggle

function Toggle:Create(x, y, txt, help, state,  w, h, hide)

	if font == nil then gfx.setfont(15, "Lucida Console", 11) end

	if w == nil then 
		ww,hh = gfx.measurestr(txt)
		w = ww + 13
	end

	if h == nil then 
		ww,hh = gfx.measurestr(txt)
		h = hh + 13
	end

	local this = {
		x = x or 10,
		y = y or 10,
		txt = txt or "X",
		help = help or "",
		w=w or 25,
		h=h or 25,
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
		block = false
	}
	setmetatable(this, Toggle)
	table.insert(Elements, this)
	return this
end

function Toggle:ResetClicks()

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

	draw_border(self.x, self.y, self.w, self.h)
	gfx.x, gfx.y = self.x, self.y

	if self.mouseDown then
		gfx.set(.24,.24,.24,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)
		
	elseif self.state == true and self.mouseOver == false then 

		gfx.set(.5,.26,.36,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)
		

	elseif self.state == true and self.mouseOver then 

		gfx.set(.55,.31,.41,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)
		

	elseif self.mouseOver and self.state == false then 

		gfx.set(.31,.31,.31,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)


	elseif self.mouseOver == false then

		gfx.set(.27,.27,.27,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	end

		gfx.set(.7,.7,.7,1)
		gfx.drawstr(self.txt, 1 | 4, self.w+self.x, self.h+self.y+2)


	if hovering(self.x, self.y, self.w, self.h) then 
		self.mouseOver = true 

		status:Display(self.help)

		if gfx.mouse_cap >= 1 and self.mouseDown == false then 
			
			if gfx.mouse_cap == 4 or gfx.mouse_cap == 8 or gfx.mouse_cap == 16 then self.mouse_down = false
			else
				self.mouseDown = true
				if gfx.mouse_cap == 1 then 
					self.leftClick = true
					if self.state == true then self.state = false else self.state = true end
				elseif gfx.mouse_cap == 2 then self.rightClick = true
				elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
				elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
				elseif gfx.mouse_cap == 10 then self.shiftRightClick = true	
				elseif gfx.mouse_cap == 17 then self.altLeftClick = true
				elseif gfx.mouse_cap == 18 then self.altRightClick = true
				elseif gfx.mouse_cap == 64 then self.middleClick = true
				
				end
			end
		elseif gfx.mouse_cap == 0 and self.mouseDown == true then
			self.mouseDown = false
		end
	else
		self.mouseOver = false
		self.mouseDown = false
	end
end

------------------------------------------END: TOGGLE---------------------------------------------------------


--------------------------------------------------------------------------------------------------------------
-----------------------------------------CLASS: HORIZOTAL SLIDER----------------------------------------------
--------------------------------------------------------------------------------------------------------------

H_slider = {}
H_slider.__index = H_slider

function H_slider:Create(x, y, w, h, txt, help, min_val, max_val, default, backwards, font, fontSize)
	
	if font == nil then gfx.setfont(15, "Lucida Console", 12) end
	if w == nil then 
		ww,hh = gfx.measurestr(txt)
		w = ww + 110
	end

	if h == nil then 
		ww,hh = gfx.measurestr(txt)
		h = hh + 15
	end

	local this = {
		x = x or 10,
		y = y or 10,
		w = w or 100,
		h = h or 40,
		txt = txt or "Slider",
		help = help or "",
		min_val = min_val or 0,
		max_val = max_val or 0,
		default = default or 0,
		backwards = backwards or false,
		value = default or 0,
		font = "Lucida Console",
		fontSize = fontSize or 12,
		mouseOver = false,
		mouseDown = false,
		leftClick = false,
		rightClick = false,
		shiftLeftClick = false,
		ctrlRightClick = false,
		ctrlLeftClick = false,
		override = false,
		hide = false,
		block = false
	}
	setmetatable(this, H_slider)
	table.insert(Elements, this)
	return this
end

function H_slider:Draw()

	if self.hide then return end

	self:ResetClicks()

	gfx.x, gfx.y = self.x, self.y
	
	draw_border(self.x, self.y, self.w, self.h, .23, .21, .7)
	draw_border(self.x+1, self.y+1, self.w-2, self.h-2, .23, .21, .7)

	
	--Formula to determine how much of the slider should be filled
	local percent = self.value / self.max_val * 100
	local fill = (percent*(self.w/100))-8


	if self.block == false and hovering(self.x-10, self.y+1, self.w+self.x, self.h-4)  then

		status:Display(self.help)
		
		if gfx.mouse_cap == 1 or self.override  then 
			self.mouseDown = true
			new_val = math.ceil(((gfx.mouse_x-self.x)/self.w)*self.max_val)
			if new_val < self.min_val then new_val = self.min_val 
			elseif new_val > self.max_val then new_val = self.max_val
			end
			self.value = new_val
		elseif gfx.mouse_cap == 2 then self.rightClick = true
		elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
		elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
		end
		if gfx.mouse_cap > 0 then self.mouseDown = true else self.mouseDown = false end
	end

	--If set to backwards handle the fill differently
	if self.backwards then 
		gfx.set(.2,.19,.6,1)
		gfx.rect(self.x+4,self.y+4, self.w-8,self.h-8,true)
		gfx.set(.2,.2,.2,1)
		gfx.rect(self.x+4,self.y+4, fill,self.h-8,true)

	else
		gfx.set(.2,.19,.6,1)
		gfx.rect(self.x+4,self.y+4, fill,self.h-8,true)
	end

	--Draw text	
	gfx.set(.7,.7,.7,1)
	gfx.x, gfx.y = self.x, self.y
	gfx.setfont(13, self.font, self.fontSize)
	gfx.drawstr(self.txt .. ": " .. self.value .. " / " .. self.max_val, 1 | 4, self.w+self.x, self.h+self.y+3)

end

function H_slider:ResetClicks()
	self.leftClick = false
	self.rightClick = false
	self.shiftLeftClick = false
	self.ctrlLeftClick = false
end

function H_slider:Reset()
	self.value = self.default
end

--------------------------------------------------------------------------------------------------------------
-------------------------------------------CLASS: DROPDOWN----------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Dropdown = {}
Dropdown.__index = Dropdown


function Dropdown:Create(x,y,w,h,choices, default, selected, help)
	
	if choices == nil then choices = {} end
	if font == nil then gfx.setfont(3, "Lucida Console", 11) end

	--Find the longest item and set the width of the dropdown accordingly
	if w == nil then 
		local longest_choice
		for l, len in ipairs(choices) do
			ww,hh = gfx.measurestr(choices[l])
			if ww > gfx.measurestr(choices[l-1]) then longest_choice = ww end
		end
		w = longest_choice + 25
	end

	if h == nil then 
		ww,hh = gfx.measurestr(choices[1])
		h = hh + 12
	end

	local this = {
		x = x or 10,
		y = y or 10,
		w = w,
		h = h, 
		choices = choices or {""},
		default = default or 1,
		selected = selected or 1,
		help = help or "",
		font = "Lucida Console",
		fontSize = fontSize or 11,
		leftClick = false,
		rightClick = false,
		choicesHide = true,
		hide = false,
		block = false
	}
	setmetatable(this, Dropdown)
	table.insert(Elements, this)
	return this

end

function Dropdown:Draw()

	if self.hide then return end

	self:ResetClicks()
	gfx.setfont(3, self.font, self.fontSize)
	draw_border(self.x, self.y, self.w, self.h)

	gfx.set(.2,.21,.24)
	gfx.rect(self.x+1, self.y+1, self.w-2, self.h-2, true)
	gfx.x, gfx.y = self.x+6, self.y+5
	gfx.set(.7,.7,.7)
	gfx.drawstr(self.choices[self.selected])
	gfx.x, gfx.y = self.x+self.w-13, self.y+5
	gfx.set(.2, .8, .2)
	gfx.drawstr("v")


	if self.choicesHide == false then self:DrawChoices() end


	if hovering(self.x, self.y, self.w, self.h) then 
		
		status:Display(self.help)
		self.mouseOver = true 
		if gfx.mouse_cap >= 1 and self.mouseDown == false then 
			self.leftClick = true
			if gfx.mouse_cap == 4 or gfx.mouse_cap == 8 or gfx.mouse_cap == 16 then self.mouse_down = false
			else
				self.mouseDown = true
				if gfx.mouse_cap == 1 then if self.choicesHide == true then self.choicesHide = false else self.choicesHide = true end
				elseif gfx.mouse_cap == 2 then self.rightClick = true
				elseif gfx.mouse_cap == 5 then self.ctrlLeftClick = true
				elseif gfx.mouse_cap == 9 then self.shiftLeftClick = true
				elseif gfx.mouse_cap == 10 then self.shiftRightClick = true	
				elseif gfx.mouse_cap == 17 then self.altLeftClick = true
				elseif gfx.mouse_cap == 18 then self.altRightClick = true
				elseif gfx.mouse_cap == 64 then self.middleClick = true
				
				end
			end
		elseif gfx.mouse_cap == 0 and self.mouseDown == true then
			self.mouseDown = false
		end
	elseif hovering(self.x, self.y, self.w, self.h) == false and gfx.mouse_cap == 1 then self.choicesHide = true 
	else
		self.mouseOver = false
		self.mouseDown = false
		
	end

end
	

function Dropdown:DrawChoices()

	local choice_height = 0



	for c, choice in ipairs(self.choices) do
		local w,h = gfx.measurestr(choice)
		choice_height = choice_height + h

	end

	gfx.set(.37,.37,.37,1)
	gfx.rect(self.x, self.y+self.h, self.w, choice_height+15, true)

	--Determine the x/y and hovering coordinates for each choice
	local choice_pos_y = 25
	for c, choice in ipairs(self.choices) do
		
		gfx.x, gfx.y = self.x+6, self.y+ choice_pos_y
		
		if c == self.selected then gfx.set(1,.7,.2) else gfx.set(.1,.1,.1) end

		if hovering(self.x+6, self.y+choice_pos_y, self.x+self.w, self.y+choice_pos_y) and gfx.mouse_cap == 1 then

		 self.selected = c
		 for wait = 0, 10000 do end
		 self.choicesHide = true
		end

		gfx.drawstr(choice)
		choice_pos_y = choice_pos_y + 12
	end

end

function Dropdown:ResetClicks()

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

function Dropdown:Reset()
end
------------------------------------------END: DROPWDOWN-----------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-------------------------------------------CLASS: STATUS----------------------------------------------------
--------------------------------------------------------------------------------------------------------------
Status = {}
Status.__index = Status

function Status:Create(x,y,w,h,title, font, fontSize, help, r, g, b)
	local this = {
		x = x or 10,
		y = y or 10,
		w = w or 100,
		h = h or 75,
		r = r or .4,
		g = g or .4,
		b = b or .4,
		title = title or "Info",
		text = "",
		help = help or "",
		font = "Lucida Console",
		fontSize = fontSize or 10,
		leftClick = false,
		rightClick = false,
		hide = false,
		block = false
	}
	setmetatable(this, Status)
	table.insert(Elements, this)
	return this

end

function Status:Draw()
	if self.hide then return end

	if hovering(self.x, self.y, self.w, self.h) then self:Display(self.help) end

	--Draw title
	gfx.set(.8,.25,.3)
	gfx.x, gfx.y = self.x+3, self.y
	gfx.setfont(4, self.font, 14)
	gfx.drawstr(self.title)
	
	--Draw frame
	gfx.set(self.r, self.g, self.b)
	gfx.roundrect(self.x, self.y+17, self.w, self.h, 4, true)
	gfx.roundrect(self.x+1, self.y+18, self.w-2, self.h-2,true)

end

function Status:Display(help_text)
	--Draw status message

	gfx.setfont(2, self.font, self.fontSize)
	gfx.x, gfx.y = self.x+10, self.y+25
	gfx.set(.7,.7,.7)
	gfx.drawstr(help_text)
end

function Status:Reset()
end


------------------------------------------END: STATUS-----------------------------------------------------





