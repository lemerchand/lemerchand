local class        =   require('middleclass')
local r            =   reaper
local format       =   string.format
local std          =   require('liblemerchand')
local tbl          =   std.table
local dbg          =   std.dbg
--  _____              __            __
-- / ___/__  ___  ___ / /____ ____  / /____
--/ /__/ _ \/ _ \(_-</ __/ _ `/ _ \/ __(_-<
--\___/\___/_//_/___/\__/\_,_/_//_/\__/___/
local PADX, PADY   =   16, 28

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

-- ______        __    ___  _          __
--/_  __/____ __/ /_  / _ \(_)__ ___  / /__ ___ __
-- / / / -_) \ / __/ / // / (_-</ _ \/ / _ `/ // /
--/_/  \__/_\_\\__/ /____/_/___/ .__/_/\_,_/\_, /
--                            /_/          /___/
TextDisplay = class('TextDisplay', BaseUIClass)

function TextDisplay:initialize(name, text, width, height)
    BaseUIClass.initialize(self, name)
    self.text     =   text
    self.height   =   height
    self.width    =   width
    self.flags    =   r.ImGui_InputTextFlags_ReadOnly()
end

function TextDisplay:Draw(text)
    self.text = text
    if	self.width == 'FULL' then
	self.w = r.ImGui_GetWindowWidth(ctx) - PADX
    else
	self.w = self.width
    end
    if	self.height == 'FULL' then
	self.h = r.ImGui_GetWindowHeight(ctx) - PADY
    else
	self.h = self.height
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

function TextDisplay:Update(change)
end
--   ____               __    ___
--  /  _/__  ___  __ __/ /_  / _ )___ __ __
-- _/ // _ \/ _ \/ // / __/ / _  / _ \\ \ /
--/___/_//_/ .__/\_,_/\__/ /____/\___/_\_\
--        /_/
InputBox = class('InputBox', BaseUIClass)

function InputBox:initialize(name, text, width, height)
    BaseUIClass.initialize(self, name)
    self.text      =   text
    self.height    =   height
    self.width     =   width
    self.entered   =   false
    self.flags     =   r.ImGui_InputTextFlags_EnterReturnsTrue()
end

function InputBox:Draw()
    if	self.width == 'FULL' then
	self.w = r.ImGui_GetWindowWidth(ctx) - PADX
    else
	self.w = self.width
    end
    self.h = (r.ImGui_GetWindowHeight(ctx) - PADY) or 200
    self.entered, self.text = r.ImGui_InputText(
	ctx,
	self.name,
	self.text,
	self.flags
	)
    if self.entered then
	local tmp = self.text
	self.text = ''
	return tmp
    else return nil end
end



-- ______             __     ______     __   __
--/_  __/______ _____/ /__  /_  __/__ _/ /  / /__
-- / / / __/ _ `/ __/  '_/   / / / _ `/ _ \/ / -_)
--/_/ /_/  \_,_/\__/_/\_\   /_/  \_,_/_.__/_/\__/
-- TODO:
--	* Possibly want to make this into parent class in case other tables are necessary
TrackView = class('TrackView', BaseUIClass)

function TrackView:initialize(name, width, height)
    BaseUIClass.initialize(self, name)
    self.width          =   width
    self.height         =   height
    self.flags          =   r.ImGui_TableFlags_RowBg() | r.ImGui_TableFlags_Resizable() |r.ImGui_TableFlags_Hideable() | r.ImGui_TableColumnFlags_WidthStretch()
    self.col_headings   =   { '#', 'Name', 'Pan', '', ''}
end

function TrackView:Draw(list)
    if  self.width == 'FULL' then
	self.w = r.ImGui_GetWindowWidth(ctx) - PADX
    else
	self.w = self.width
    end
    if  self.height == 'FULL' then
	self.h = r.ImGui_GetWindowHeight(ctx) - PADY
    else
	self.h = self.height
    end

    r.ImGui_BeginTable(ctx, self.name, 5, self.flags)

    -- Setup the columns
    for _, heading in ipairs(self.col_headings) do
	r.ImGui_TableSetupColumn(ctx, heading)
    end
    r.ImGui_TableHeadersRow(ctx)

    local change = nil

    -- Create rowstext
    for i = 1, #list do
	local track = list[i]

	r.ImGui_TableNextRow(ctx)
	r.ImGui_TableSetColumnIndex(ctx, 0)
	r.ImGui_Text(ctx, track.number + 1)

	r.ImGui_TableSetColumnIndex(ctx, 1)
	local nameChanged, name = r.ImGui_InputText(
		ctx,
		format('##%s', track.number),
		track.name,
		r.ImGui_InputTextFlags_AutoSelectAll() --| r.ImGui_InputTextFlags_EnterReturnsTrue()
		)

	if nameChanged then change = {track=track.number, name = track.name, attr='P_NAME', new_value=name} end

	r.ImGui_TableSetColumnIndex(ctx, 2)
	r.ImGui_PushAllowKeyboardFocus(ctx, false)
	local panChanged, pan = reaper.ImGui_SliderInt(
		ctx,
		format('##%span', track.number),
		math.floor(track.pan * 100),
		-100,
		100
		)
	r.ImGui_PopAllowKeyboardFocus(ctx)

	if panChanged then change = {track=track.number, name = track.name, attr='D_PAN', new_value=pan * .01} end

	r.ImGui_TableSetColumnIndex(ctx, 3)
	if track.color then
	    local colorChanged, color  = r.ImGui_ColorButton(
		    ctx,
		    format('##%scolor', track.number),
		    Convert_native_to_hex(track.color)
		    )
	end
    end
    r.ImGui_EndTable(ctx)
    return change
end

function TrackView:Update(change)
    if change.attr == 'P_NAME' then r.GetSetMediaTrackInfo_String(
	    r.GetTrack(0, change.track),
	    change.attr,
	    change.new_value,
	    true
	    )
    return
    end

    r.SetMediaTrackInfo_Value(
	r.GetTrack(0, change.track),
	change.attr,
	change.new_value
	)
end

--  _____                   __
-- / ___/__  ___  ___ ___  / /__  ___ _
--/ /__/ _ \/ _ \(_-</ _ \/ / _ \/ _ `/
--\___/\___/_//_/___/\___/_/\___/\_, /
--                              /___/
-- TODO: Find out how to keep the scrolling
--	up-to-date with text (log-stlye)
Clog = class('Clog', BaseUIClass)

function Clog:initialize(name, text, width, height)
    BaseUIClass.initialize(self, name)
    self.text     =   text
    self.height   =   height
    self.width    =   width
    self.flags    =   r.ImGui_InputTextFlags_ReadOnly()
end

function Clog:Draw(dummy)
    dummy = dummy
    if	self.width == 'FULL' then
	self.w = r.ImGui_GetWindowWidth(ctx) - PADX
    else
	self.w = self.width
    end
    if	self.height == 'FULL' then
	self.h = r.ImGui_GetWindowHeight(ctx) - PADY
    else
	self.h = self.height
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

function Clog:log(text, ...)
    local arg = {...}
    if not arg[1] then arg[1] = '' end
    if #arg >= 1 then
	local arg_check = 0

	for i = 1, #text do
	    if text:sub(i, i) == '%' then arg_check = arg_check + 1 end
	end

	local safety_args = arg_check - #arg
	for _ = 1, safety_args do table.insert(arg, '') end
    end


    local datetime = os.date('%x%I:%M')
    self.text = format(self.text ..  datetime .. ': ' .. tostring(text) .. '\n', table.unpack(arg))
end



