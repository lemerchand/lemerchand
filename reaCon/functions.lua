--------------------------------------------------------------------------------------------------------------
----------------------------------File Functions----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

function exit()

end



function dbg(txt, clear)
	if clear then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(txt))
end



--------------------------------------------------------------------------------------------------------------
----------------------------------MAIN Functions----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

function update_display()
	display:ClearLines()
	if c.prefix then display:AddLine('Prefix: ' .. c.prefix) end
	if c.trackStr then display:AddLine('Tracks: ' .. c.trackStr) end
	if c.args then display:AddLine('Args: ' .. c.args) end
	if c.rop then display:AddLine('ROP: ' .. c.rop) end
	if c.secondaryStr then display:AddLine('Secodary: ' .. c.secondaryStr) end
	if c.routing then display:AddLine('Routing ' .. c.routing) end


end

function update_cli()

	if c.prefix == 't' then c:select_tracks()
	elseif c.prefix == 'c' then 
	elseif c.prefix == 'C' then 
	elseif c.prefic == 'd' then
	elseif c.prefix == 'n' then

	end	
end

--------------------------------------------------------------------------------------------------------------
----------------------------------CLI Object----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


CLI = {}
CLI.__index = CLI

function CLI:Create()
	local this = {
		prefix = nil,
		trackStr = nil,
		tracks = {
			id={},
			userData={},
			name={},
			soloed={},
			muted={},
			armed={},
			parent={},
			fxEn={},
			color={}
		},
		args = nil,
		rop = nil,
		secondaryStr = nil,
		secondary = {
			id={},
			name={},		
		},
		routing=nil,
		engaged = false,
		history = {id={}, txt={}}
	}

	setmetatable(this, CLI)
	return this
end

function CLI:Reset()
	self.prefix = nil
	self.trackStr = nil
	self.tracks = {
		id={},
		userData={},
		name={},
		soloed={},
		muted={},
		armed={},
		parent={},
		fxEn={},
		color={}
	}
	self.args = nil
	self.rop = nil
	self.secondaryStr = nil
	self.secondary = {
		id={},
		name={},		
		}
	self.routing = nil
	self.engaged = false
end

function CLI:Parse(txt)

	self.engaged = true
	local trimmed = txt
	local trimmedRouting = nil

	-- Find the prefix
	local prefix = txt:find('%s')
	self.prefix = txt:sub(1,prefix)
	
	-- Find the string (TODO: needs further parsing)
	if prefix then trimmed = txt:sub(prefix+1) end

	-- If a routing symbol occurs, split the string (second half)
	if trimmed:find('[<>]') then 
		self.rop = trimmed:match('[<>]')
		trimmedRouting = trimmed:sub(trimmed:find('[<>]')+1)
	else self.rop = nil
	end
	
	-- If a routing symbol occurs, split string (first half)
	if trimmedRouting then 
		trimmed = trimmed:sub(1, trimmed:find('[<>]')-1)
	end

	-- Look for the end of tracks
	self.args = trimmed:match('=([%w%p]*)')

	-- If we find an end set trackString and trim
	if self.args then 
		self.trackStr = trimmed:sub(1, trimmed:find('=')-1)
	elseif prefix then 
		self.trackStr = trimmed:gsub('=', '')
	end

	-- Gather routing info
	if trimmedRouting then
		self.routing = trimmedRouting:match('=([%a%d%p]*)')
		if self.routing then 
			self.secondaryStr = trimmedRouting:gsub('=' .. self.routing, '')
		elseif trimmedRouting then  
			self.secondaryStr = trimmedRouting:gsub('=', '')
		end
	end
end