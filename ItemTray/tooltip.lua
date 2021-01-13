tips = {}
Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip:Create(tip, x, y, time, fgColor, bgColor, font, fontSize)
-- tip = text to display
-- time = time before self-destruct
-- [fg/bg]Color = {r, g, b}

	local this = {
		tip = tip or nil,
		time = time or 25,
		x = x or gfx.mouse_x + 30,
		y = y or gfx.mouse_y,
		tr = fgColor[1] or .1,
		tg = fgColor[2] or .1,
		tb = fgColor[3] or .1,
		br = bgColor[1] or .1,
		bg = bgColor[2] or .6,
		bb = bgColor[3] or .4,
		font = font or 'Arial',
		fontSize = fontSize or 12,
		w = 0,
		h = 0,
		enabled = true
	}

	setmetatable(this, Tooltip)
	table.insert(tips, this)
	return this

end

function Tooltip:Draw()

	if not self.enabled then return end
	self.hide = false

	self.w = 125
	self.h = 120


	gfx.set(self.br, self.bg, self.bb)
	gfx.rect(self.x, self.y, self.w, self.h)
	
	gfx.set(self.tr, self.tg, self.tb)
	gfx.x = self.x + 2
	gfx.y = self.y + 2
	gfx.drawstr(self.tip)

end



