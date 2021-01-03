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
	
	local r = r or .45
	local g = g or .45
	local b = b or .45
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

function Button:Create(x, y, txt, name, editor, take, item, w, h, color, font, fontSize,hide)

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
		editor = editor or nil,
		name = name or nil, 
		take = take or nil,
		item = item or nil,
		w=w or 30,
		h=h or 30,
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
		fontSize = fontSize or 12,
		active=false
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
	
	local r, g, b = .3, .3, .3
	
	if self.color then 
		r, g, b = reaper.ColorFromNative( self.color ) 
		r = r / 255 
		g = g / 255 
		b = b / 255 
	end

	if r == 0 then r = .3 end
	if g == 0 then g = .3 end
	if b == 0 then b = .3 end


	gfx.setfont(16, self.font, self.fontSize, 'b')

	draw_border(self.x, self.y, self.w, self.h)
	gfx.x, gfx.y = self.x, self.y

	if self.mouseDown == true then

		gfx.set(r-.3,g-.3,b-.3,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	elseif self.mouseOver then 

		gfx.set(r+.1,g+.1,b+.1,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	elseif self.mouseOver == false then

		gfx.set(r-.05, g-.05, b-.05,1)
		gfx.rect(self.x+1,self.y+1,self.w-2,self.h-2, true)

	end

	-- if r > g and r > b then r = r -.05 ; b = b+.1
	-- elseif g > r and g > b then g = g - .05 ; b=b+.1
	-- elseif b > r and b > g then b = b - .05 ; r = r +.1
	-- end

	if r+g+b > 1.2 then
		gfx.set(.2, .2, .2)
	elseif r+g+b > 9 then
		gfx.set(.3, .3, .3)
	else gfx.set(.7, .7, .7)
	end

	--if (r <= .3 and g <= .3 and b <= .3) or not self.color then gfx.set(.7,.7,.7) else gfx.set(r-.3, g-.3, b-.3) end

	if self.name then 
		gfx.x, gfx.y = self.x-6, self.y-self.fontSize
		gfx.drawstr(self.txt, 1 | 4, self.w+self.x, self.h+self.y)
		gfx.x, gfx.y = self.x-6, self.y+self.fontSize+(self.fontSize*.5)
		gfx.drawstr(self.name, 1 | 4, self.w+self.x, self.h+self.y)
	else
		gfx.x = self.x-5
		gfx.drawstr(self.txt, 1 | 4, self.w+self.x, self.h+self.y+3)
	end

	if hovering(self.x, self.y, self.w, self.h) then 
		
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


function Button:restore_ME()
	--TODO: Store and restore selected media items
	local starttime = reaper.GetMediaItemInfo_Value(self.item, 'D_POSITION')
	reaper.SelectAllMediaItems(0, false)
	reaper.SetEditCurPos(starttime , true, true )
	reaper.SetMediaItemSelected(self.item, true )
	reaper.Main_OnCommand(40153, 0)
	self.active = true
end
-------------------------------------------END: BUTTON--------------------------------------------------------