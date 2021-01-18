-- Toolbar Code
is_new_value,filename,section_ID,cmd_ID,mode,resolution,val = reaper.get_action_context()
reaper.SetToggleCommandState(section_ID, cmd_ID, 1)
reaper.RefreshToolbar2(section_ID, cmd_ID)

-- Variables
local leftClick = false
local rightClick =  false
local lastTrack, lastTrackName, startingX, endingX


-- Degbug
reaper.ClearConsole()
function dbg(txt)
	reaper.ShowConsoleMsg('\n' .. tostring(txt))
end

-- Mouse interceptions
function intercept_mouse()
	tIntercepts = {WM_LBUTTONDOWN = false,
		WM_LBUTTONUP = false,
		WM_LBUTTONDBLCLK = false,
		WM_RBUTTONDOWN = false,
		WM_RBUTTONUP = false,
		WM_MOUSEMOVE = false,
		WM_SETCURSOR = false
	}
	midiview = reaper.JS_Window_FromPoint(reaper.GetMousePosition())
	for key, value in pairs(tIntercepts) do
		OK = reaper.JS_WindowMessage_Intercept(midiview, key, value)
	end
end

function on_exit()
	reaper.JS_WindowMessage_ReleaseAll()
	-- Set toolbar button to off
	reaper.SetToggleCommandState(section_ID, cmd_ID, 0);
	reaper.RefreshToolbar2(section_ID, cmd_ID);
end

-----------------------------------
--[		 Script Functions		]--
-----------------------------------

function set_selection_start()
	-- Move edit cursor to mouse (no snappinng)
	reaper.Main_OnCommand(40514, 0)
	-- Move to left grid division
	reaper.Main_OnCommand(40646, 0)
	-- Set selection start point
	reaper.Main_OnCommand(40625, 0)
end

function set_selection_end()

	-- Move edit cursor to mouse (no snappinng)
	reaper.Main_OnCommand(40514, 0)

	-- If the user dragged left switch start/end points
	if startingX > endingX then 
		set_selection_start()
		reaper.SetEditCurPos( startingX, false, false )
		
		-- Move edit cursor to the start of next grid line
		reaper.Main_OnCommand(40647, 0)
	else
		-- Move edit cursor to the start of next grid line
		reaper.Main_OnCommand(40647, 0)
	end
	-- Set selection end point
	reaper.Main_OnCommand(40626, 0)
end

function insert_midi_items(track, trackName)
	-- Unselect all tracks
	reaper.Main_OnCommand(40297, 0)
	-- Selet target track
	reaper.SetTrackSelected(track, true)
	-- Insert empty midi item
	reaper.Main_OnCommand(40214, 0)
	
	-- Name the take after the track
	local item = reaper.GetSelectedMediaItem(0, 0)
	local take = reaper.GetActiveTake(item)
	local length = reaper.BR_GetMidiSourceLenPPQ(take)
	reaper.MIDI_InsertNote( take, false, false, 0, length, 1, 100, 66, false )
	reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', trackName, true)
	
	-- Trim to avoid layers
	reaper.Main_OnCommand(40930, 0)
	-- Split items on grid
	reaper.Main_OnCommand(40932, 0)
	-- Remove selection
	reaper.Main_OnCommand(40635, 0)

	if startingX <= endingX then 
		reaper.SetEditCurPos(startingX, true, false)
	else
		reaper.SetEditCurPos(endingX, true, false)
	end
	-- Move to left grid division
	reaper.Main_OnCommand(40646, 0)

end

function remove_items(track)
	-- Unselect all tracks
	reaper.Main_OnCommand(40297, 0)
	-- Select track
	reaper.SetTrackSelected(track, true)
	-- Unselect items
	reaper.Main_OnCommand(40289, 0)
	-- Select items in time selection
	reaper.Main_OnCommand(40718, 0)
	-- Remove item
	reaper.Main_OnCommand(40697, 0)
	-- Remove selection
	reaper.Main_OnCommand(40635, 0)
end


-----------------------------------
--[			  					]--
--[			   MAIN				]--
--[								]--
-----------------------------------

function main()
	
	local window, segment, details = reaper.BR_GetMouseCursorContext()
	if reaper.JS_Mouse_GetState(-1) >= 4 then 
		reaper.JS_WindowMessage_ReleaseAll()
	elseif segment == 'track' then
		reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(185))
		intercept_mouse()
		reaper.Undo_BeginBlock()
		-- Select track under mouse/save it as curTrack
		reaper.Main_OnCommand(41110, 0)
		local curTrack = reaper.GetSelectedTrack(0, 0)

		----------------------------------------------------------------------------------
		--- CODE FOR DETERMINING CHANGE OF TRACK
		-- Leaving in case it is needed later
		-- Check to see if the track has changed and the mouse is down...
		-- If so, [1] end the current selection
		-- [2a-b] Treat last track as if the mouse has been released
		-- 		Reset the click so that it resets the start selection process over	

		-- if curTrack ~= lastTrack and (rightClick or leftClick) then
		--  	endingX =  reaper.BR_PositionAtMouseCursor( true )
		--  	set_selection_end()												-- [1]

		--  	if leftClick then 
		--  		insert_midi_items(lastTrack, lastTrackName)					-- [2a]
		 		
		--  	end
		--  	if rightClick then 
		--  		remove_items(lastTrack)										-- [2b]
		 		
		--  	end
		-- end
		---------------------------------------------------------------------------------

		-- Select the hovered-over track again (incase it got deselected)
		-- Record current track as the last track and get it's name
		reaper.SetTrackSelected(curTrack, true)
		lastTrack = curTrack
		local retval, trackName = reaper.GetTrackName(curTrack)
		lastTrackName = trackName
	
		-----------------------------------
		--[			Addng Items			]--
		-----------------------------------
		-- If LMB down and it hasn't been clicked yet..
		-- [1] Flag it
		-- [2] Halt the UI refresh
		-- [3] Check for items under the house--if none...
		-- [4] Set the time selection
		if reaper.JS_Mouse_GetState(1) == 1 and not leftClick then
			
			leftClick = true 												-- [1]
			reaper.PreventUIRefresh(2)										-- [2]

			-- Select track under mouse
			local mx, my = reaper.GetMousePosition()						
			local item, take = reaper.GetItemFromPoint(mx, my, false)		-- [3]
			
			-- Store to determine direction
			startingX =  reaper.BR_PositionAtMouseCursor( true )

			-- If the mouse is in an empty track lane
			if not item and details == 'empty' then 
				set_selection_start()										-- [4]
			else leftClick = false
			end

		-- If LMB down and dragging...
		-- [5] Compare OG mouse xpos to current
		-- [6] Set the slection end
		-- [7] Insert a midi item in the time selection
		-- [8] Reset flag

		elseif reaper.JS_Mouse_GetState(1) == 0 and leftClick then
				reaper.PreventUIRefresh(-2)
				endingX = reaper.BR_PositionAtMouseCursor( true )
				set_selection_end()											-- [6]
				insert_midi_items(curTrack, trackName)						-- [7]
				leftClick = false											-- [8]
				reaper.Undo_EndBlock('Insert Triggers', -1)
	
		-----------------------------------
		--[		  Removing Items		 ]--
		-----------------------------------
		-- If RMB first time...
		-- Flag rightClick, prevent UI refresh, set time selection start

		elseif reaper.JS_Mouse_GetState(-1) == 2 and not rightClick then 
			rightClick = true
			reaper.PreventUIRefresh(2)
			-- Store to determine direction
			startingX =  reaper.BR_PositionAtMouseCursor( true )
			set_selection_start()

		-- If RMB drag...
		-- Prevent that refresh, end the time selection, remove the items
		-- on curTrack, reset rightClick flag
		elseif reaper.JS_Mouse_GetState(-1) == 0 and rightClick then
			reaper.PreventUIRefresh(2)
			endingX = reaper.BR_PositionAtMouseCursor( true )
			set_selection_end()
			remove_items(curTrack)
			rightClick = false
		end
			
		-- Relieve UI Refresh prevention/Mouse intercepts
		reaper.PreventUIRefresh(-2)
	elseif segment ~= 'track' then
		reaper.JS_WindowMessage_ReleaseAll()
	end
	
	-----------------------------------
	--[			Defer Mngmt			 ]--
	-----------------------------------

	if reaper.JS_VKeys_GetState(-1):byte(27) == 1 then
		reaper.atexit(on_exit)
		return
	else
		reaper.defer(main)
	end
end
main()
reaper.atexit(on_exit)
