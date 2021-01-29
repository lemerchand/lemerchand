
--------------------------------------------------------------------------------------------------------------
----------------------------------File Functions----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
function exitnosave()

end
function exit()
	save_window_settings()
	save_history()
end

function save_window_settings()
	local file = io.open(script_path .. 'windowsettings.dat', 'w')
	io.output(file)
	file:write('width=' .. gfx.w .. '\n')
	file:write('height=' .. gfx.h .. '\n')
	file:close()
end


function load_window_settings()
	local width, height
	local file = io.open(script_path .. 'windowsettings.dat', 'r')
	if not file then return end
	io.input(file)
	while true do
		local line = file:read()
		if not line then break end

		if line:match('width=(%d+)') then 
			width = line:match('width=(%d+)') 
		elseif line:match('height=(%d+)') then
			height = line:match('height=(%d+)')

		end


	end	
	file:close()
	return width, height
end

function save_history()
	local file = io.open(script_path .. 'history.dat', 'w')
	io.output(file)
	for h, his in ipairs(c.history) do
		file:write(his .. '\n')
		if h == 20 then break end
	end
	file:close()
end

function load_file_into_table(filename)
	local t = {}
	local file = io.open(script_path .. filename, 'r')
	if not file then return end
	io.input(file)
	while true do
		local line = file:read()
		if not line then 
			break
		end
		if line ~= "" then
			table.insert(t, line)
		end
	end
	file:close()
	return t
end

--------------------------------------------------------------------------------------------------------------
----------------------------------Debug Functions----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------


function log(txt, clear)
	if clear then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(txt))
end

function dbg(clear)
	if clear then reaper.ClearConsole() end
	log('-----------------------------')
	log('--Context: ' .. c.context)
	log('-----------------------------')
	if c.prefix then
		log('Prefix: ' ..  c.prefix)
	end
	log('Cpos: ' .. cmd.cpos)
	log('\n\n---------------------------')
	log('--c.Tracks:')
	log('----------------------------')
	for i, t in ipairs(c.tracks.name) do
		log('\t' .. i .. '. C Track: ' .. t)
	end
	for i, nt in ipairs(c.newtracks) do
		log('\tNew: ' .. nt)
	end
	log('\n\n---------------------------')
	log('--Sec Tracks:')
	log('----------------------------')
	for i, t in ipairs(c.secondary.name) do
		log('\t' .. i .. '. Sec Track: ' .. t)
	end
	log('\n\n---------------------------')
	log('--Routing:')
	log('----------------------------')
	if c.rop then log('C.rop: ' .. c.rop) end
	if c.routing then 
		log(c.secondary.name[1])
		log('\n\t' .. c.routing)
	end	
	log('\n\n---------------------------')
	log('--Prev Sel Tracks:')
	log('----------------------------')

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
			userData={},
			name={},
			soloed={},
			muted={},
			armed={},
			parent={},
			fxEn={},
			color={}
		},
		routing=nil,
		engaged = false,
		candidates = {},
		context = 'MAIN',
		exclusive = false,
		newtracks = {},
		history = {},
		historySeek = 0
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
	self.newtracks = {}
	self.args = nil
	self.rop = nil
	self.secondaryStr = nil
	self.secondary = {
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
	self.routing = nil
	self.engaged = false
	self.candidates = {}
	self.context = 'MAIN'
	self.exclusive = false
	self.historySeek = 0
end

function CLI:Reset_tracks()
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
	self.candidates = {}
	self.newtracks = {}
end

function CLI:Reset_secondary()
	self.secondary = {
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
end

function CLI:PrevCLI()
	if not self.history then return end
	if self.historySeek == #self.history then return
	else
		self.historySeek = self.historySeek + 1
		cmd.txt = self.history[self.historySeek]
	end

	cmd.cpos = string.len(cmd.txt)
end

function CLI:NextCLI()

	if self.historySeek == 0 then return
	elseif self.historySeek == 1 then
		cmd.txt = ""
		self.historySeek = 0
	else
		self.historySeek = self.historySeek - 1
		cmd.txt = self.history[self.historySeek]
	end
	cmd.cpos = string.len(cmd.txt)
end

--------------------------------------------------------------------------------------------------------------
----------------------------------MAIN Functions----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
function CLI:Parse(txt)
	
	--self.engaged = true
	local trimmed = txt
	local trimmedRouting = nil

	-- Find the prefix
	local prefix = txt:find('%s')
	if prefix then self.prefix = txt:sub(1,prefix-1) end

	-- Find the string (TODO: needs further parsing)
	if prefix then trimmed = txt:sub(prefix+1) end

	-- If a routing symbol occurs, split the string (second half)
	if trimmed:find('[<>%{%}]') then 
		self.rop = trimmed:match('[<>%{%}]')
		trimmedRouting = trimmed:sub(trimmed:find('[<>%{%}]')+1)
	else self.rop = nil
	end
	
	-- If a routing symbol occurs, split string (first half)
	if trimmedRouting then 
		trimmed = trimmed:sub(1, trimmed:find('[<>%{%}]')-1)
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
		if self.secondaryStr:sub(1,1) == ' ' then
			self.secondaryStr = self.secondaryStr:sub(2)
		end
	end
end

function CLI:Select_tracks()

	if self.trackStr and not self.rop then 
		self:Reset_tracks()
		self.candidates = self:Parse_tracks(self.trackStr)
	else return
	end

	-- Unselect all tracks
	reaper.Main_OnCommand(40297, 0)

	local trackCount = reaper.CountTracks(0)
	for i = 0, trackCount - 1 do
		local tr = reaper.GetTrack(0, i)
		local ret, trackName = reaper.GetTrackName(tr)
		trackName = string.lower(trackName..'!')
		for n, name in ipairs(self.candidates) do
			if trackName:find(string.lower(name)) then
				reaper.SetTrackSelected(tr, true)				
			end
		end
	end
end

function CLI:Select_secondary_tracks()
	self:Reset_secondary()
	if not self.secondaryStr then return end


	-- Unselect all tracks
	reaper.Main_OnCommand(40297, 0)

	local trackCount = reaper.CountTracks(0)

	for i = 0, trackCount - 1 do
		local tr = reaper.GetTrack(0, i)
		local ret, trackName = reaper.GetTrackName(tr)
		trackName = string.lower(trackName)
		if trackName:find(string.lower(self.secondaryStr)) then
			reaper.SetTrackSelected(tr, true)
		end
		if reaper.CountSelectedTracks(0) == 1 then 
			get_selected_track_info(self.secondary, i, tr) 
		end
	end 
end

function CLI:Parse_tracks(trackStr)
	local results = {}
	for tmp in trackStr:gmatch('([^,]*)') do
		if tmp:sub(1,1) == ' ' then tmp = tmp:sub(2) end
		if tmp:sub(-1,-1) == ' ' then tmp = tmp:sub(1,-2) end
		table.insert(results, tmp)
		
	end
	return results
end

function CLI:update_cli()
	
	-- Engage ad store selected tracks
	if not c.engaged and cmd.txt ~= "" then 
		c.prevSelectedTracks = store_selected_tracks()
		c.engaged = true
	end

	-- Display the right prefix information
	local p = cmd.txt:sub(1,1)
	if p == 't' or p == 'T'
		and (not self.args and not self.rop) then
			self.context = 'SELECTTRACKS'
			if p == 't' then 
				self.exclusive = false
			else self.exclusive = true 
			end
			self:Select_tracks()
	elseif p == 'c'
		or p == 'C' then  
			c.context = "CLEAR"
	elseif p == 'R' then
		self.context = 'REMOVETRACKS'
		self:Select_tracks()
	elseif p == 'n' then
		self.context = 'CREATETRACKS'
	end	

	-- Display routing and adoption info
	if self.rop == '<' or self.rop == '>' then
		self.context = 'SECONDARY'
		self:Select_secondary_tracks()
	elseif self.rop == '{' or self.rop == '}' then

		self.context = 'ADOPTION'
		self:Select_secondary_tracks()
	end

-----------------------------------
--[		  User Commited		 	]--
-----------------------------------

	if cmd.returned and cmd.txt ~= '' then  
		reaper.PreventUIRefresh(1)
		reaper.Undo_BeginBlock()
		table.insert(self.history, 1, cmd.txt)
		c.historySeek = 0

		-- New tracks
		if self.prefix == 'n' then 
			--unselect ll tracks
			reaper.Main_OnCommand(40297, 0)
			self.newtracks = self:Parse_tracks(self.trackStr)
			create_new_tracks(self.newtracks)
			
			reaper.UpdateArrange()
			local trackCount = reaper.CountTracks(0)
		
			for i = 0, trackCount - 1 do
				local track = reaper.GetTrack(0, i)
				
				if reaper.IsTrackSelected(track) then
					get_selected_track_info(self.tracks, i, track)
					
				end
			end
		end

		-- Handle arguments
		if self.args then 
			if c.context=="SECONDARY" then select_tracks_from_list(self.tracks.userData) end
			self:handle_args() 
		end

		-- Handle Routing
		if self.rop == '<' or self.rop == '>' then self:handle_routing() end

		-- Handle adoption
		if self.rop == '{' or self.rop == '}' then self:handle_adoption() end

		--Handle everythig else
		if not self.args and not self.rop then handle_else() end

		
		-- Scroll the mixer to the selected track 
		if reaper.CountSelectedTracks(0) >=1 then reaper.SetMixerScroll( reaper.GetSelectedTrack(0, 0)) end
		

		if not c.exclusive then 
			restore_tracks(c.prevSelectedTracks, true)
		end
		-- Rese errthang
		cmd.txt = ""
		cmd.returned = false
		cmd.active = true
		self:Reset()


		reaper.PreventUIRefresh(-1)
	end

end

function select_tracks_from_list(tracks)
	-- Unselect all tracks
	reaper.Main_OnCommand(40297, 0)

	for i, track in ipairs(tracks) do
		reaper.SetTrackSelected(track, true)
	end

end

function get_selected_track_info(tracks, index, tr)

	table.insert(tracks.id , index)
	local ret, name = reaper.GetTrackName(tr)
	table.insert(tracks.name , name)
	table.insert(tracks.userData , tr)
	
	if reaper.GetMediaTrackInfo_Value(tr,'I_SOLO') > 0 then 
		table.insert(tracks.soloed , true)
	else table.insert(tracks.soloed , false)
	end

	if reaper.GetMediaTrackInfo_Value(tr,'B_MUTE') == 1 then 
		table.insert(tracks.muted, true)
	else table.insert(tracks.muted, false)
	end	

	if reaper.GetMediaTrackInfo_Value(tr,'I_RECARM') > 0 then 
		table.insert(tracks.armed, true)
	else table.insert(tracks.armed, false)
	end

	if reaper.GetMediaTrackInfo_Value(tr,'I_FXEN') > 0 then 
		table.insert(tracks.fxEn, true)
	else table.insert(tracks.fxEn, false)
	end

	if reaper.GetMediaTrackInfo_Value(tr,'I_FOLDERDEPTH') > 0 then 
		table.insert(tracks.parent, true)
	else table.insert(tracks.parent,false)
	end

	table.insert(tracks.color, reaper.GetMediaTrackInfo_Value(tr,'I_CUSTOMCOLOR'))

	--[[
		id={index},
		userData={tr},
		name={name},
		soloed={},
		muted={},
		armed={},
		parent={},
		fxEn={},
		color={}
	]]--

end

function CLI:handle_args()
	--Look for mute 
	if self.args:find("m%-") then set_sel_track_params('B_MUTE', 0, false)
	elseif self.args:find("m%+") then set_sel_track_params('B_MUTE', 1, false)
	elseif self.args:find("m") then set_sel_track_params('B_MUTE',-1, false)
	elseif self.args:find('M%+') then set_sel_track_params('B_MUTE', 1, true)
	elseif self.args:find('M%-') then set_sel_track_params('B_MUTE', 0, true)
	elseif self.args:find("M") then set_sel_track_params('B_MUTE',-1, true)
	end

	--Look for solo
	if self.args:find("o%-") then set_sel_track_params("I_SOLO", 0, false)
	elseif self.args:find("o%+") then set_sel_track_params('I_SOLO', 1, false)
	elseif self.args:find("o") then set_sel_track_params('I_SOLO',-1, false)
	elseif self.args:find("O%+") then set_sel_track_params('I_SOLO', 1, true)	
	elseif self.args:find("O%-") then set_sel_track_params('I_SOLO', 0, true)
	elseif self.args:find("O") then set_sel_track_params('I_SOLO', -1, true)
	end

	--Look for arm
	if self.args:find("a%-") then set_sel_track_params("I_RECARM", 0, false)
	elseif self.args:find("a%+") then set_sel_track_params('I_RECARM', 1, false)
	elseif self.args:find("a") then set_sel_track_params('I_RECARM',-1, false)
	elseif self.args:find("A%-") then set_sel_track_params('I_RECARM', 0, true)
	elseif self.args:find("A%+") then set_sel_track_params('I_RECARM', 1, true)
	elseif self.args:find("A") then set_sel_track_params('I_RECARM', -1, true)
	end

	--Look for fx bypass
	if self.args:find("b%-") then set_sel_track_params("I_FXEN", 0, false)
	elseif self.args:find("b%+") then set_sel_track_params('I_FXEN', 1, false)
	elseif self.args:find("b") then set_sel_track_params('I_FXEN',-1, false)
	elseif self.args:find("B%+") then set_sel_track_params('I_RECARM', 1, true)
	elseif self.args:find("B%-") then set_sel_track_params('I_RECARM', 0, true)
	elseif self.args:find("B") then set_sel_track_params('I_FXEN', -1, true)
	end

	if c.args:find('f') then reaper.Main_OnCommand(reaper.NamedCommandLookup('_S&M_TOGLFXCHAIN'), 0) end
	
	--Look for custom color 
	if c.args:find("c") then 
		local color = ""
		if c.args:find('c%d+') then 	
			color = '_SWS_TRACKCUSTCOL' .. c.args:match('c(%d*)') 
		else 
			color = "RANDOM"
		end
		if color == "RANDOM" then reaper.Main_OnCommand(reaper.NamedCommandLookup('_SWS_TRACKRANDCOL'), 0)
		else reaper.Main_OnCommand(reaper.NamedCommandLookup(color), 0)
		end
	end

	--look for record input
	if c.args:find("i%d*") then 
		local midiChannel = c.args:match("i%d+")
		if midiChannel then midiChannel = midiChannel:sub(2) else midiChannel = 0 end
		set_sel_track_params("I_RECINPUT", 4096 | midiChannel | (63 << 5))
		set_sel_track_params("I_RECMODE", 7)
	end
	if c.args:find("I%d*") then 
		local midiChannel = c.args:match("i%d+")
		if audioChannel then audioChannel = audioChannel:sub(2) else midiChannel = 0 end
		set_sel_track_params("I_RECINPUT", 0)
		set_sel_track_params("I_RECMODE", 0)
	end
end

function CLI:handle_routing()
	local midiSourceChannel = nil
	local midiDestinationChannel = nil

	local audioSourceChannel = nil
	local audioDestinationChannel = nil

	-- look for midi routing
	if self.routing:find("m%d+") then
		midiSourceChannel = self.routing:match("m%d+")
	end

	if self.routing:find("m%d+%+?:%d+") then
		midiDestinationChannel = self.routing:match(":%d+")
		
	end

	-- Look for audio routing
	if self.routing:find("a%d+") then
		audioSourceChannel = self.routing:match("a%d+")
	end

	if self.routing:find("a%d+%+?:%d+") then
		audioDestinationChannel = self.routing:match(":%d+")
	end


	if midiSourceChannel then 
		midiSourceChannel = midiSourceChannel:sub(2) 
	else midiSourceChannel = 0 end
	
	if midiDestinationChannel then 
		midiDestinationChannel = midiDestinationChannel:sub(2) 
	else midiDestinationChannel = 0 end

	if audioSourceChannel then 
		audioSourceChannel = audioSourceChannel:sub(2) 
	else audioSourceChannel = 0 end
	
	if audioDestinationChannel then 
		audioDestinationChannel = audioDestinationChannel:sub(2)
	else audioDestinationChannel = 0 end
	
	audioSourceChannel = audioSourceChannel - 1
	audioDestinationChannel = audioDestinationChannel - 1
	audioSourceChannel = audioSourceChannel + audioSourceChannel
	audioDestinationChannel = audioDestinationChannel + audioDestinationChannel

	for t, tr in ipairs(self.tracks.userData) do
 		
		local strack = tr
		 
		if self.rop == ">" then
			local tracksends = reaper.GetTrackNumSends(strack, 0)

			reaper.CreateTrackSend(strack, self.secondary.userData[1])
			reaper.BR_GetSetTrackSendInfo(strack, 0, tracksends, 'I_MIDI_SRCCHAN', true, tonumber(midiSourceChannel)) 
			reaper.BR_GetSetTrackSendInfo(strack, 0, tracksends, 'I_MIDI_DSTCHAN', true, tonumber(midiDestinationChannel))
			reaper.BR_GetSetTrackSendInfo(strack, 0, tracksends, 'I_SRCCHAN', true, tonumber(audioSourceChannel)) 
			reaper.BR_GetSetTrackSendInfo(strack, 0, tracksends, 'I_DSTCHAN', true, tonumber(audioDestinationChannel))

			if self.routing:find("m%d+%+:") then midiSourceChannel = midiSourceChannel + 1 end
			if self.routing:find("m%d+%+?:%d+%+") then midiDestinationChannel = midiDestinationChannel + 1 end

			if self.routing:find("a%d+%+:") then audioSourceChannel = audioSourceChannel + 2 end
			if self.routing:find("a%d+%+?:%d+%+") then audioDestinationChannel = audioDestinationChannel + 2 end
		
		elseif self.rop == "<" then
			local tracksends = reaper.GetTrackNumSends(strack, -1)

			reaper.CreateTrackSend(self.secondary.userData[1], strack)
			reaper.BR_GetSetTrackSendInfo(strack, -1, tracksends , 'I_MIDI_SRCCHAN', true, tonumber(midiSourceChannel)) 
			reaper.BR_GetSetTrackSendInfo(strack, -1, tracksends , 'I_MIDI_DSTCHAN', true, tonumber(midiDestinationChannel))
			reaper.BR_GetSetTrackSendInfo(strack, -1, tracksends , 'I_SRCCHAN', true, tonumber(audioSourceChannel)) 
			reaper.BR_GetSetTrackSendInfo(strack, -1, tracksends , 'I_DSTCHAN', true, tonumber(audioDestinationChannel))
			
			if self.routing:find("m%d+%+:") then midiDestinationChannel = midiDestinationChannel + 1 end
			if self.routing:find("m%d+%+?:%d+%+") then midiSourceChannel = midiSourceChannel + 1 end

			if self.routing:find("a%d+%+:") then audioDestinationChannel = audioDestinationChannel + 2 end	
			if self.routing:find("a%d+%+?:%d+%+") then audioSourceChannel = audioSourceChannel + 2 end						

		end

	

	end	
end

function CLI:handle_adoption()
	-- unselect all trcks
	reaper.Main_OnCommand(40297, 0)
	for i, t in ipairs(c.tracks.userData) do
		reaper.SetTrackSelected(t, true)
	end
	
	
	if c.rop == '}' then 
		
		reaper.ReorderSelectedTracks(c.secondary.id[1]+1, 1)
		
	elseif c.rop == '{' then
		reaper.ReorderSelectedTracks(c.secondary.id[1], 0)
	end

end

function handle_else()
	local tracks = reaper.CountTracks(0)

	if cmd.txt == 'dbg'then dbg() end

	if cmd.txt == "C" then
		for i = 0, tracks - 1 do
			track = reaper.GetTrack(0, i)
			reaper.SetMediaTrackInfo_Value(track, 'B_MUTE', 0)
			reaper.SetMediaTrackInfo_Value(track, 'I_SOLO', 0)
			reaper.SetMediaTrackInfo_Value(track, 'I_RECARM', 0)
			reaper.SetTrackSelected(track, false)
		end
	elseif cmd.txt == "c" then
		for i = 0, tracks - 1 do
			track = reaper.GetTrack(0, i)
			reaper.SetTrackSelected(track, false)
		end
	elseif c.prefix == 'R' then 
		for tr = tracks-1, 0, -1 do
			if reaper.IsTrackSelected(reaper.GetTrack(0,tr)) then reaper.DeleteTrack(reaper.GetTrack(0, tr)) end
		end	
	end
end

--Sets selected tracks param with state 
function set_sel_track_params(param, state, exclusive)

	local trackCount = reaper.CountTracks(0)
	if c.args:find('B') then reaper.SetMediaTrackInfo_Value(reaper.GetMasterTrack(0), param, math.abs(reaper.GetMediaTrackInfo_Value( reaper.GetMasterTrack(0), param)-1)) end

	for i = 0, trackCount - 1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) then 

			if state == -1 then
				reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, i), param, math.abs(reaper.GetMediaTrackInfo_Value( reaper.GetTrack(0,i), param)-1))

			else
				reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), param, state)
			end
		end

		--if exclusive mode then fuck this track in it's asshole
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) == false and exclusive then 
			reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), param, 0)

		end
	end
end

function create_new_tracks(tracks)
	
	for i, nt in ipairs(tracks) do
		local totalTracks = reaper.CountTracks(0)
		reaper.InsertTrackAtIndex(totalTracks, true)
		reaper.GetSetMediaTrackInfo_String( reaper.GetTrack(0, totalTracks), 'P_NAME', nt, true )
		reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0, totalTracks), 'I_RECMON', 1 )
		reaper.SetTrackSelected(reaper.GetTrack(0, totalTracks), true)

	end

end

function restore_tracks(track, keepothers)
	local tracks = reaper.CountTracks(0)
	for i = 0, tracks-1 do
		if track[i] == true then
			reaper.SetTrackSelected(reaper.GetTrack(0, i), true)
		else
			if not keepothers then 
				reaper.SetTrackSelected(reaper.GetTrack(0, i), false)	
			end
		end
	end
end

function store_selected_tracks()
	local selectedTracks = {}
	local tracks = reaper.CountTracks(0)
	for i = 0, tracks - 1 do
		if reaper.IsTrackSelected(reaper.GetTrack(0,i)) 
			then selectedTracks[i] = true
		else
			selectedTracks[i] = false
		end
	end
	return selectedTracks
end