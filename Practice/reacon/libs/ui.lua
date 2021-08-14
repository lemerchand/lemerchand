rDoFile('libs/middleclass.lua')
local class = middleclass
local r = reaper

--                    __            __
-- _______  ___  ___ / /____ ____  / /____
--/ __/ _ \/ _ \(_-</ __/ _ `/ _ \/ __(_-<
--\__/\___/_//_/___/\__/\_,_/_//_/\__/___/

local PADX, PADY = 16, 28 

--   ___                 __  ______  _______
--  / _ )___ ____ ___   / / / /  _/ / ___/ /__ ____ ___
-- / _  / _ `(_-</ -_) / /_/ // /  / /__/ / _ `(_-<(_-<
--/____/\_,_/___/\__/  \____/___/  \___/_/\_,_/___/___/

BaseUIClass = class('BaseUIClass')

function BaseUIClass:initialize(name)
    self.name = '##' .. name
end

function BaseUIClass:ClearText()
    self.text = ''
end

--     ___          __
-- ___/ (_)__ ___  / /__ ___ __
--/ _  / (_-</ _ \/ / _ `/ // /
--\_,_/_/___/ .__/_/\_,_/\_, /
--         /_/          /___/

TextDisplay = class('TextDisplay', BaseUIClass)

function TextDisplay:initialize(name, text, width, height)
    BaseUIClass.initialize(self, name)
    self.text = text
    self.height = height
    self.width = width
    self.flags =  r.ImGui_InputTextFlags_ReadOnly()
end

function TextDisplay:Draw()
    if self.width == 'FULL' then
	self.w = r.ImGui_GetWindowWidth(ctx) - PADX
    else self.w = self.width
    end
    if self.width == 'FULL' then
	self.h = r.ImGui_GetWindowHeight(ctx) - PADY
    else self.h = self.height
    end
    self.retval, self.text = r.ImGui_InputTextMultiline(
	    ctx,
	    self.name,
	    self.text,
	    self.w,
	    self.h,
	    self.flags
    )
end

--   _                __    __
--  (_)__  ___  __ __/ /_  / /  ___ __ __
-- / / _ \/ _ \/ // / __/ / _ \/ _ \\ \ /
--/_/_//_/ .__/\_,_/\__/ /_.__/\___/_\_\
--      /_/

InputBox = class('InputBox', BaseUIClass)

function InputBox:initialize(name, text, width, height)
    BaseUIClass.initialize(self, name)
    self.text = text
    self.height = height
    self.width = width
    self.entered = false
    self.flags =  r.ImGui_InputTextFlags_EnterReturnsTrue()
end

function InputBox:Draw()
    if self.width == 'FULL' then
	self.w = r.ImGui_GetWindowWidth(ctx) - PADX
    else self.w = self.width
    end
    self.h = (r.ImGui_GetWindowHeight(ctx) - PADY) or 200
    self.entered, self.text = r.ImGui_InputText(
	    ctx,
	    self.name,
	    self.text,
	    self.flags
    )
end
