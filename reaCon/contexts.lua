-- @noindex

local lastChar = ''

function update_display()
	if c.context == 'SELECTTRACKS' then
		track_display(c.tracks)
	elseif c.context == 'SECONDARY' then
		 track_display(c.secondary)
	elseif c.context == 'ADOPTION' then
		track_display(c.secondary)
	elseif c.context == 'CREATETRACKS' then
		create_track_display()
	elseif c.context == 'REMOVETRACKS' then
		track_display(c.tracks)
	elseif c.context == 'MAIN' then 
		main_display()
	elseif c.context == 'CLEAR' then 
		clear_tracks_display()
	elseif c.context == 'SCRIPTUTILS' then
		scriptutils_display()
	end
end


function main_display()
	display:ClearLines()
	display2:ClearLines()
	display:AddLine('**oThis is** **vwhere** **gI will** **bput some** **sinfo**')

end

function clear_tracks_display()
	display2:ClearLines()
	if cmd.txt:sub(1,1) == 'C' then 
		display2:AddLine('**sReset and unselect all tracks...**')
	elseif cmd.txt:sub(1,1) == 'c' then
		display2:AddLine('**sUnselect all tracks...**')
	end
end

function create_track_display()
	help_tracks()
end

function display_routing()
	local tracktype
	if c.prefix == 'n' then 
		tracktype = 'new'
	elseif c.prefix == 't' or c.prefix == 'T' then 
		tracktype = 'selected'
	end
	if c.rop == '>' then 
		display:AddLine('**ySend ' .. tracktype ..' track(s) to ...**')
	elseif c.rop == '<' then 
		display:AddLine('**y' .. tracktype .. ' track(s) receive from...**')
	end
end

function display_adoption()
	local tracktype
	if c.prefix == 't' or c.prefix == 'T' then
		tracktype = 'Selected'
	elseif c.prefix == 'n' then
		tracktype = 'New'
	end
	if c.rop == '}' then 
		display:AddLine('**y' .. tracktype ..' track(s) adopted by ...**')
	elseif c.rop == '{' then 
		display:AddLine('**y' .. tracktype .. ' track(s) disowned by...**')
	end

end

function track_display(tracks)
	
	local selectedTracks = 0
	display:ClearLines()

	if c.context == 'SECONDARY' then display_routing() end
	if c.context == 'ADOPTION' then display_adoption() end

	local trackCount = reaper.CountTracks(0)
	for i = 0, trackCount -1 do

		local track = reaper.GetTrack(0, i)
		if reaper.IsTrackSelected(track) then
			selectedTracks = selectedTracks + 1
			get_selected_track_info(tracks, i, track)
			
			local displayName = i+1 .. '. ' .. tracks.name[#tracks.name]
			if tracks.muted[#tracks.name] then 
				displayName = '**r' .. displayName .. '**' 
			end
			if tracks.soloed[#tracks.name] then 
				displayName = '**y' .. displayName .. '**'
			end
			if tracks.armed[#tracks.name] then 
				displayName = '**g' .. displayName .. '**'
			end
			if tracks.fxEn[#tracks.name] == false then 
				displayName = '**e' .. displayName .. '**'
			end
			if tracks.parent[#tracks.name] then 
				displayName = displayName .. '**bº**' 
			end
			display:AddLine(displayName)
		end
	end

	if reaper.CountSelectedTracks(0) == 1 then 
		c.subcontext = 'INSPECTTRACK'
		display_inspect_track() 
	else
		c.subcontext = 'NONE'
	end

	-- Help Display
	if c.context == 'SELECTTRACKS'
		or c.context == 'CREATETRACKS' then 
		help_tracks()
	elseif c.context == 'REMOVETRACKS' then
		help_remove_tracks()
	end
end
	

function help_remove_tracks()
	display2:ClearLines()
	local helmpmsg = ''
	local selTracks = reaper.CountSelectedTracks(0)
	helpmsg = '**sRemove ' .. selTracks .. ' tracks**'
	display2:AddLine(helpmsg)
end

function help_tracks()
	display2:ClearLines()
	local intentions = {}
	local helpmsg = ''
	local tracks = nil
	if c.prefix == 'n' then 
		helpmsg = 'Make '
		tracks = #(c:Parse_tracks(c.trackStr))
	elseif c.context == 'SELECTTRACKS' then 
		tracks =  reaper.CountSelectedTracks(0)
	end

	if c.args then 
		if intends_to_mute() then table.insert(intentions, '**rMute**') end
		if intends_to_solo() then table.insert(intentions, '**ySolo**') end
		if intends_to_arm() then table.insert(intentions, '**gArm**') end
		if intends_to_toggleFX() then table.insert(intentions, '**eToggle FX**') end
		if intends_to_toggleFX_visibility() then table.insert(intentions, '**bShow/Hide FX**') end

		if #intentions > 1 then
			for i = 1, #intentions-1 do
				helpmsg = helpmsg .. intentions[i] .. ', '
			end
			helpmsg = helpmsg .. 'and ' .. intentions[#intentions] .. ' '

		elseif #intentions == 1 then helpmsg = intentions[1] .. ' '
		end

		if intends_to_toggleFX_visibility() or intends_to_toggleFX() then
			helpmsg = helpmsg .. 'on '
		end

	end

	if not c.trackStr then 
		if c.context == 'SELECTTRACKS' then 
			helpmsg = '**sBegin typing to filter tracks...**'
		elseif c.context == 'CREATETRACKS' then
			helpmsg = '**sNew track(s)... **'
		end
	
	else
		if tracks > 1 then 
			tracks = tostring(tracks) .. ' tracks'
			helpmsg = helpmsg .. tracks
		else
			tracks = tostring(tracks) .. ' track'
			helpmsg = helpmsg .. tracks
		end
		if not c.args and c.context == 'SELECTTRACKS' then 
			helpmsg = helpmsg .. ' selected' 
		end
	end


	display2:AddLine(helpmsg)
end

function display_inspect_track()

	local track = reaper.GetSelectedTrack(0, 0)
	-- Pan
	local trackPan = reaper.GetMediaTrackInfo_Value(track, 'D_PAN')
	if trackPan == 0 then trackPan = '**gC **'
	elseif trackPan < 0 then trackPan = tostring(math.floor((trackPan*100)*-1)) .. '% L'
	elseif trackPan > 0 then trackPan = tostring(math.floor(trackPan*100)) .. '% R'
	end	
	display:AddLine('   **oPan: **' .. trackPan)
	
	-- Rec mode
	local recInput = reaper.GetMediaTrackInfo_Value(track, 'I_RECINPUT')
	if recInput == 1024 then 
		recInput = 'Stereo'
	elseif recInput == 6112 then recInput = '**bMIDI:** All'
	elseif recInput >= 6113 and recInput <= 6128 then 
		recInput = '**bMIDI:** ' .. math.floor(recInput-6112)
	else recInput = '**bMono:** ' .. math.floor(recInput + 1)
	end
	display:AddLine('   **oInput: **')
	display:AddLine('      ' .. recInput)

	-- Sends
	local trackSendCount = reaper.GetTrackNumSends(track, 0)
	local trackReceiveCount = reaper.GetTrackNumSends(track, -1)
	if trackSendCount == 0 and trackSendCount == 0 then goto notes end
	
	if trackSendCount == 0 then goto receives end
	-- SENDS
	display:AddLine('')
	display:AddLine('   **oSends:** ' .. trackSendCount)
	for i = 0, trackSendCount - 1 do
		local send =  reaper.GetTrackSendInfo_Value( track, 0, i, 'P_DESTTRACK' )
		local ret, sendName = reaper.GetTrackName(send)
		local sendDChan = math.floor(reaper.GetTrackSendInfo_Value(track, 0, i, 'I_DSTCHAN')+1)
		local sendSChan = math.floor(reaper.GetTrackSendInfo_Value(track, 0, i, 'I_SRCCHAN')+1)
		local sendSMChan = math.floor(reaper.BR_GetSetTrackSendInfo(track, 0, i, 'I_MIDI_SRCCHAN', false, 0))
		local sendDMChan = math.floor(reaper.BR_GetSetTrackSendInfo(track, 0, i, 'I_MIDI_DSTCHAN', false, 0))

		display:AddLine('      **b' .. i+1 .. '. ' .. sendName .. '**')
		if sendSChan ~= -1 and sendDChan ~= -1 then
			display:AddLine('          Audio: ' ..sendSChan .. ' : ' .. sendDChan)
		end	
		
		if sendSMChan == 0 then sendSMChan = 'A' end
		if sendDMChan == 0 then sendDMChan = 'A' end
		display:AddLine('          MIDI:  ' .. sendSMChan .. ' : ' .. sendDMChan)
		display:AddLine('')
	end

	::receives::
	-- RECEIVES
	if trackReceiveCount == 0 then goto notes end
	display:AddLine('   **oReceives:** ' .. trackReceiveCount, yellow.r, yellow.g, yellow.b)
	for i = 0, trackReceiveCount - 1 do
		local rec =  reaper.GetTrackSendInfo_Value( track, -1, i, 'P_SRCTRACK' )
		local ret, recName = reaper.GetTrackName(rec)
		local recDChan = math.floor(reaper.GetTrackSendInfo_Value(track, -1, i, 'I_DSTCHAN')+1)
		local recSChan = math.floor(reaper.GetTrackSendInfo_Value(track, -1, i, 'I_SRCCHAN')+1)
		local recSMChan = math.floor(reaper.BR_GetSetTrackSendInfo(track, -1, i, 'I_MIDI_SRCCHAN', false, 0))
		local recDMChan = math.floor(reaper.BR_GetSetTrackSendInfo(track, -1, i, 'I_MIDI_DSTCHAN', false, 0))

		display:AddLine('      **b' .. i+1 .. '. ' .. recName .. '**')
		if recSChan ~= -1 and recDChan ~= -1 then 
			display:AddLine('          Audio: ' ..recSChan .. ' : ' .. recDChan)
		end
		
		if recSMChan == 0 then recSMChan = 'A' end
		if recDMChan == 0 then recDMChan = 'A' end
		display:AddLine('          MIDI:  ' .. recSMChan .. ' : ' .. recDMChan)
		display:AddLine('')
	end

	::notes::
	local notes =  reaper.NF_GetSWSTrackNotes( track )
	display:AddLine('   **oNotes: **')
	for line in notes:gmatch('[^\n]+') do
		display:AddLine('      ' .. line)
	end

	
end


function scriptutils_display()
		
		display:ClearLines()
		display2:ClearLines()
		local window, segment, details = reaper.BR_GetMouseCursorContext()
		local char = gfx.getchar()
		local mouse = reaper.JS_Mouse_GetState(-1)
		display:AddLine("**yScripting Utilities**")
		display:AddLine('')								
		display:AddLine("**bMouse Cap:** " .. mouse)
		display:AddLine("**bLast Character:** " .. lastChar )
		display2:AddLine("**sPress** **w'ESC'** **sto return**")
		if char ~= 0 and char ~= lastChar then lastChar = char end
		if char == 27 then 
			
			cmd.txt = ''
			cmd.active = true
			c.context = 'MAIN' 
			update_display()
		else
			reaper.defer(scriptutils_display)
		end
end

function text_editor_display()

	display:ClearLines()
	display:AddLine(c.subcontext)


end

function load_track_notes(track)
	local trackNotes = reaper.NF_GetSWSTrackNotes(track)
	editor.lines = {}
	for line in trackNotes:gmatch('[^\n]+') do
		table.insert(editor.lines, line)
	end 
	if #editor.lines == 0 then editor.lines[1] = '' end
end

function save_track_notes(track)
	local str = table.concat(editor.lines, '\n')
	reaper.NF_SetSWSTrackNotes(track, str)
end


function intends_to_mute()
	if c.args:find('m') or c.args:find('M') then return true else return false end
end
function intends_to_solo()
	if c.args:find('o') or c.args:find('O') then return true else return false end
end
function intends_to_arm()
	if c.args:find('a') or c.args:find('A') then return true else return false end
end
function intends_to_toggleFX()
	if c.args:find('b') or c.args:find('B') then return true else return false end
end
function intends_to_toggleFX_visibility()
	if c.args:find('f') then return true else return false end
end
