
Elements = {}

----------------------------
--Custom Colors-------------
----------------------------
-- default = {r=.75, g=.75, b=.75}
-- white = {r=.95, g=.95, b=.95}
-- red = {r=.7, g=.1, b=.2}
-- orange = {r=1, .6, 0}
-- yellow = {r=.75, g=.7, b=.3}
-- green = {r=.2, g=.65, b=.11}
-- blue = {r=.25, g=.5, b=.9}
-- violet = {r=.5, g=.1, .6}
-- grey = {r=.41, g=.4, b=.37}
-- something = {r=.65, g=.25, b=.35}



function colorSplit(str)
	local result = {}
	local tmp = str
	while true do
		local c, t, e = str:match('%*%*(%a)(.-)(%*%*)')
		if c and t and e then 
			tmp = str:sub(1, str:find(c)-3)
			table.insert(result, {color=default, rstr=tmp})
			table.insert(result, {color=get_color_by_letter(c), rstr=t})

			local ss, se = str:find(t..e)
			if not se then break end
			str = str:sub(se+2)
			
		else 
			table.insert(result, {color=default, rstr=str})
			break
		end
	end
	return result
end

function get_color_by_letter(c)
	if c == 'r' then return red 
	elseif c == 'w' then return white
	elseif c == 'g' then return green
	elseif c == 'b' then return blue
	elseif c == 'e' then return grey
	elseif c == 'y' then return yellow
	elseif c == 's' then return something
	elseif c == 'o' then return orange
	elseif c == 'v' then return violet
	else 
		return default
	end
end

function draw_elements()
	for e, element in ipairs(Elements) do
		element:Draw()
	end
end

--Draws an empty rectangle
function draw_border(x,y,w,h, r, g, b, fill)
	
	local r = r or .45
	local g = g or .45
	local b = b or .45
	gfx.set(r, g, b, 1)
	gfx.rect(x,y,w,h, fill)
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
--------------------------------------------------------------------------------------
---------------------------------GUI UPDATE------------------------------------------
--------------------------------------------------------------------------------------

function refresh(refresh)
	if refresh == 0 then 
		update_ui()
		return 5
	else
		return refresh -1
	end
end


function update_ui()

	mainFrame.x, mainFrame.y = 10, 10
	mainFrame.w = gfx.w - 20
	mainFrame.h = gfx.h - 25

	cmd.x = mainFrame.x + 1
	cmd.w = mainFrame.w -1
	cmd.h = cmd.fontSize + 8
	cmd.y =  mainFrame.h - 8

	display.x = mainFrame.x+10
	display.w = mainFrame.w - 20
	display.y = mainFrame.y
	display.h = cmd.y - 60

	display2.x = mainFrame.x+10
	display2.w = mainFrame.w - 20
	display2.y = display.y + display.h + 20
	display2.h = cmd.y-5


end



--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: FRAME----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Frame = {}
Frame.__index = Frame

function Frame:Create(x,y,w,h)
	
	local this = {
		x = x or 10,
		y = y or 10,
		w = w or 100,
		h = h or 100,
		r = .4,
		g = .4,
		b = .4,
		hide = hide or false,
	}

	setmetatable(this, Frame)
	table.insert(Elements, this)
	return this
end

function Frame:Draw()

	if self.hide then return end
	
	--Draw frame
	gfx.set(self.r, self.g, self.b)
	gfx.roundrect(self.x, self.y, self.w, self.h, 4, true)
	gfx.roundrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, true)


end

function Frame:Reset()

end

------------------------------------END: FRAME----------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: TEXT FIELD-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


TextField = {}
TextField.__index = TextField

function TextField:Create(x,y, w, h, txt, active, multiline, font, fontSize, r, g, b)

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
		blink = 0

	}

	setmetatable(this, TextField)
	table.insert(Elements, this)
	return this
end

function TextField:Draw()
	self:ResetClicks()
	if self.hide then return end

	draw_border(self.x-1, self.y-1, self.w+2, self.h+2)
	draw_border(self.x,self.y, self.w,self.h)
	draw_border(self.x+1, self.y+1,self.w-2,self.h-2, .22,.22,.22, true)

	gfx.x, gfx.y = self.x+5, self.y+5
	gfx.set(self.r, self.g, self.b, 1)
	gfx.setfont(1, self.font, self.fontSize)
	
	local txtlen = string.len(self.txt)
	local charwidth = gfx.measurestr("-")


	if self.active  and self.blink <= 15 then 
		gfx.x = self.x+5 + (self.cpos * charwidth)
		gfx.y = self.y+10
		gfx.drawstr( "-")
		self.blink = self.blink + 1
	elseif self.active and  self.blink <=30 then
		gfx.x = self.x+10 + (self.cpos * charwidth)
		gfx.drawstr( " ")
		self.blink = self.blink + 1
	else
		gfx.x = self.x+10 + (self.cpos * charwidth)
		gfx.drawstr( "")
		self.blink = 1
	end

	gfx.x, gfx.y = self.x+5, self.y+5
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
	elseif self.active and char == 1818584692 and self.cpos >=1 then
		self.cpos = self.cpos - 1
	elseif self.active and char == 6647396 then self.cpos = string.len(self.txt)
	elseif self.active and char == 1752132965 then self.cpos = 0
	end


	if self.active and gfx.measurestr(self.txt) + self.x <= self.w-10 then
		if char >= 33 and char <= 126 then 

			self.txt = self.txt:sub(1,self.cpos) .. string.char(char) .. self.txt:sub(self.cpos+1)

			--self.txt = self.txt .. string.char(char) 
			self.cpos = self.cpos + 1
		elseif char == 32 then 
			self.txt = self.txt:sub(1, self.cpos) .. " " .. self.txt:sub(self.cpos+1)
			self.cpos = self.cpos + 1
		end
	end


	if self.active and char == 8 then 
		self.txt = self.txt:sub(1, self.cpos-1) .. self.txt:sub(self.cpos+1)
		self.cpos = self.cpos - 1
		if self.cpos == -1 then self.cpos = 0 end
	elseif self.active and char == 6579564 then
		self.txt = self.txt:sub(1, self.cpos) .. self.txt:sub(self.cpos+2)
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

--------------------------------------------------------------------------------------------------------------
----------------------------------CLASS: Display-----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

Display = {}
Display.__index = Display

function Display:Create(x,y, w, h, r, g, b, font, fontSize, hide)

	if font == nil then gfx.setfont(1, "Lucida Console", 13) end

	local this = {
		x = x or 10,
		y = y or 10,
		w = w,
		h = h,
		fontSize = fontSize or 12,
		r = r or .7,
		g = g or .7,
		b = b or .7,
		font = font or "Lucida Console",
		hide = hide or false,
		lines = {line={}, col={}, r={},g={},b={}}

	}

	setmetatable(this, Display)
	table.insert(Elements, this)
	return this
end

function Display:GetOffset()

	local offset = 0
	for l, line in ipairs(self.lines.line) do
		local len = gfx.measurestr(line)
		if len > offset then offset = len end
	end
	return offset + self.fontSize + 5
end

function Display:Draw()
	self:ResetClicks()
	if self.hide then return end

	gfx.setfont(1, self.font, self.fontSize)
	
	local offsetX = 0
	local manualOffsetX = 0
	local offsetY = 0
	local heightCap = math.floor(self.h/self.fontSize)

	for l = 1, #self.lines.line do
		
		local splitStr = colorSplit(self.lines.line[l])

		if self.lines.col[l] ~= -1 then manualOffsetX = self.lines.col[l] else manualOffsetX = 0 end

		local lineMod = l%heightCap
		if lineMod == 0 then lineMod = heightCap end

		
		gfx.x, gfx.y = self.x + offsetX + manualOffsetX, self.y + lineMod*self.fontSize
		
		if #splitStr == 0 then 
			gfx.set(self.lines.r[l], self.lines.g[l], self.lines.b[l])
			gfx.drawstr(self.lines.line[l])
		else
			for t, section in ipairs(splitStr) do
				gfx.set(section.color.r, section.color.g, section.color.b)
				gfx.drawstr(section.rstr)
			end
		end


		if lineMod == heightCap then 
			offsetX = offsetX + self:GetOffset()
		end


	end



	if hovering(self.x, self.y, self.w, self.h-18) then
		
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

function Display:ResetClicks()

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

function Display:AddLine(str, red, green, blue, column)

	local red, green, blue = red or self.r, green or self.g, blue or self.b
	local column = column or -1


	table.insert(self.lines.line, str)
	table.insert(self.lines.col, column)
	table.insert(self.lines.r, red)
	table.insert(self.lines.b, blue)
	table.insert(self.lines.g, green)

end

function Display:ClearLines()
	self.lines.line	= {}
	self.lines.col	= {}
	self.lines.r	= {}
	self.lines.b	= {}
	self.lines.g 	= {}
end


function Display:Reset()

end
----------------------------------END: Display------------------------------------------------------------------
