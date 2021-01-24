-- @version 0.5.3
-- @author Lemerchand
-- @about FL Studio-style Editing Suite - Draw Tool. Left-click/drag draws. Right-click/drag erases. ESC exits.
-- @provides
--    [main] .
-- @changelog
--    + Toggling pitches/opening midi items works in Draw Mode
--    + Drag a pattern to copy it elsewhere and pool the midi

-- Toolbar Code
is_new_value, filename, section_ID, cmd_ID, mode, resolution, val = reaper.get_action_context()
reaper.SetToggleCommandState(section_ID, cmd_ID, 1)
reaper.RefreshToolbar2(section_ID, cmd_ID)

-- Variables
local leftClick = false
local rightClick = false
local patternLeftClick = false
local patternRightClick = false
local curTrack, trackName, lastTrack, lastTrackName, startingX, endingX, startingCurPos, mouseDownContext

local tIntercepts = {}

function reset_intercepts()
    tIntercepts = {
        WM_LBUTTONDOWN = false,
        WM_LBUTTONUP = false,
        WM_RBUTTONDOWN = false,
        WM_RBUTTONUP = false,
        WM_MOUSEMOVE = false,
        WM_SETCURSOR = false
    }
end

reset_intercepts()

-- Degbug
reaper.ClearConsole()
function dbg(txt, clear)
    if clear then
        reaper.ClearConsole()
    end
    reaper.ShowConsoleMsg("\n" .. tostring(txt))
end

-- Mouse interceptions
function intercept_mouse(tInntercepts)
    midiview = reaper.JS_Window_FromPoint(reaper.GetMousePosition())
    for key, value in pairs(tIntercepts) do
        OK = reaper.JS_WindowMessage_Intercept(midiview, key, value)
    end
end

function on_exit()
    reaper.JS_WindowMessage_ReleaseAll()
    -- Set toolbar button to off
    reaper.SetToggleCommandState(section_ID, cmd_ID, 0)
    reaper.RefreshToolbar2(section_ID, cmd_ID)
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
        reaper.SetEditCurPos(startingX, false, false)

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
    reaper.MIDI_InsertNote(take, false, false, 0, length, 1, 60, 66, false)
    reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", trackName, true)

    -- Trim to avoid layers
    reaper.Main_OnCommand(40930, 0)
    -- Split items on grid
    reaper.Main_OnCommand(40932, 0)
    -- Remove selection
    reaper.Main_OnCommand(40635, 0)
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
    reaper.Main_OnCommand(40006, 0)
    -- Remove selection
    reaper.Main_OnCommand(40635, 0)
end

function store_starting_cursor_pos()
    startingCurPos = reaper.GetCursorPosition()
end

function restore_staring_cursor_pos()
    reaper.SetEditCurPos(startingCurPos, true, false)
end

function hovering_over_pattern()
    local mx, my = reaper.GetMousePosition()
    local item = reaper.GetItemFromPoint(mx, my, true)
    if not item then
        return nil
    end
    local take = reaper.GetActiveTake(item)
    if is_pattern(take) then
        return item
    end
end

function is_pattern(take)
    local takeName = reaper.GetTakeName(take)
    if takeName:find("Pattern") then
        reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(186))
        return true
    end
    return false
end

function a_pattern_is_selected()
    local itemCount = reaper.CountSelectedMediaItems(0)
    local patternCount = 0

    if itemCount == 0 then
        return false
    end
    for i = 0, itemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local take = reaper.GetActiveTake(item)
        if is_pattern(take) then
            patternCount = patternCount + 1
        end
    end

    if patternCount == 1 then
        return true
    else
        return false
    end
end

function insert_sample(track)
    reaper.PreventUIRefresh(1)
    if track == nil then
        -- Insert a new track with rs5k template
        -- Assign new track to track

        -- New track
        reaper.Main_OnCommand(40001, 0)
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_APPLY_TRTEMPLATE1"), 0)

        -- Get new track
        track = reaper.GetSelectedTrack(0, 0)
    end

    local p1 = "(RS5K)"
    local p2 = "ReaSamplOmatic5000"

    local fxCount = reaper.TrackFX_GetCount(track)
    if fxCount == 0 then
        reaper.TrackFX_GetByName(track, "ReaSamplOmatic5000 (Cockos)", true)
        fxCount = 1
    end

    for i = 0, fxCount - 1 do
        local ret, fx = reaper.TrackFX_GetFXName(track, i, "")
        if fx:find(p1) or fx:find(p2) then
            reaper.TrackFX_Show(track, i, 3)

            local me = reaper.JS_Window_Find("Media Explorer", true)
            reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 42121, 0, 0, 0)
            reaper.TrackFX_Show(track, i, 2)
            break
        end
    end
    mouseDownContext = nil
    reaper.PreventUIRefresh(-1)
    reaper.JS_WindowMessage_ReleaseAll()
    return
end

-----------------------------------
--[			  					]--
--[	     CLICK HANDLERS     	]--
--[								]--
-----------------------------------

function handle_pattern_left_click()
    if reaper.JS_Mouse_GetState(1) == 1 and not patternLeftClick then
        patternLeftClick = true
        reaper.PreventUIRefresh(1)
        reaper.SelectAllMediaItems(0, false)
        reaper.SetMediaItemSelected(patternClipHover, true)
        -- Select pattern's grouped items
        reaper.Main_OnCommand(40034, 0)
        reaper.UpdateArrange()
    elseif reaper.JS_Mouse_GetState(1) == 0 then
        patternLeftClick = false
    end
end

function handle_unknown_window_click()
    -- Fuck this media explorer bullshit
    if reaper.JS_Mouse_GetState(-1) == 1 then
        local winChild = reaper.JS_Window_GetFocus()
        local win = reaper.JS_Window_GetParent(winChild)
        local me = reaper.JS_Window_Find("Media Explorer", true)
        if win == me then
            handle_media_explorer_click()
        end
    else
        reaper.JS_WindowMessage_ReleaseAll()
        mouseDownContext = nil
    end
end

function handle_media_explorer_click()
    intercept_mouse()
    reaper.JS_WindowMessage_Post(me, "WM_LBUTTONUP", 0, 0, 0, 0)
    mouseDownContext = "me"
    reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(182))
end

function handle_release_pattern_left_drag()
    reaper.PreventUIRefresh(1)
    if details == "empty" and a_pattern_is_selected() then
        -- Copy pattern
        reaper.Main_OnCommand(40698, 0)
        -- Edit cursor to mouse
        reaper.Main_OnCommand(40513, 0)
        -- Paste and pool
        reaper.Main_OnCommand(41072, 0)
    end
    reaper.PreventUIRefresh(-1)
    patternLeftClick = false
end

function handle_drag_to_tcp()
    -----------------------------------
    -----------------------------------
    --[			  Drawing			]--
    -----------------------------------
    -----------------------------------
    if mouseDownContext == "me" then
        reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(182))
    end
    -- if the user is dragging into the tcp
    if (reaper.JS_Mouse_GetState(-1) == 1 or reaper.JS_Mouse_GetState(-1) == 2) and mouseDownContext == "track" then
        intercept_mouse()
    elseif reaper.JS_Mouse_GetState(-1) == 0 and mouseDownContext == "me" then
        local track = reaper.BR_GetMouseCursorContext_Track()
        insert_sample(track)
        mouseDownContext = nil
    elseif mouseDownContext ~= "me" then
        reaper.JS_WindowMessage_ReleaseAll()
        mouseDownContext = nil
    end
end

function handle_left_mouse_pressed_on_track()
    reaper.PreventUIRefresh(1)
    store_starting_cursor_pos()
    leftClick = true
    mouseDownContext = "track" -- [1]

    -- Select track under mouse
    local mx, my = reaper.GetMousePosition()
    local item, take = reaper.GetItemFromPoint(mx, my, false) -- [3]

    -- Store to determine direction
    startingX = reaper.BR_PositionAtMouseCursor(true)

    -- If the mouse is in an empty track lane
    if not item and details == "empty" then
        set_selection_start() -- [4]
    else
        leftClick = false
    end
end

function handle_left_mouse_released_on_track()
    reaper.PreventUIRefresh(1)
    endingX = reaper.BR_PositionAtMouseCursor(true)
    set_selection_end() -- [6]
    insert_midi_items(curTrack, trackName) -- [7]
    leftClick = false -- [8]
    mouseDownContext = nil
    reaper.Undo_EndBlock("Insert Items", -1)
    restore_staring_cursor_pos()
    reaper.PreventUIRefresh(-1)
end

function handle_right_mouse_pressed_on_track()
    rightClick = true
    mouseDownContext = "track"
    store_starting_cursor_pos()
    reaper.PreventUIRefresh(1)
    -- Store to determine direction
    startingX = reaper.BR_PositionAtMouseCursor(true)
    set_selection_start()
end

function handle_right_mouse_released_on_track()
    reaper.PreventUIRefresh(1)
    endingX = reaper.BR_PositionAtMouseCursor(true)
    set_selection_end()
    remove_items(curTrack)
    reaper.Undo_EndBlock("Delete items", -1)
    restore_staring_cursor_pos()
    rightClick = false
    mouseDownContext = nil
    reaper.PreventUIRefresh(-1)
end

function handle_cursor_on_track()
    reaper.JS_Mouse_SetCursor(reaper.JS_Mouse_LoadCursor(185))
    intercept_mouse()

    -- Select track under mouse/save it as curTrack
    reaper.Main_OnCommand(41110, 0)
    curTrack = reaper.GetSelectedTrack(0, 0)

    -- Select the hovered-over track again (incase it got deselected)
    -- Record current track as the last track and get it's name
    reaper.SetTrackSelected(curTrack, true)

    _, trackName = reaper.GetTrackName(curTrack)

    -----------------------------------
    --[			Addng Items			]--
    -----------------------------------
    -- If LMB down and it hasn't been clicked yet..
    -- [1] Flag it
    -- [3] Check for items under the house--if none...
    -- [4] Set the time selection
    if reaper.JS_Mouse_GetState(1) == 1 and not leftClick and not patternLeftClick then
        -- If LMB down and dragging...
        -- [5] Compare OG mouse xpos to current
        -- [6] Set the slection end
        -- [7] Insert a midi item in the time selection
        -- [8] Reset flag
        handle_left_mouse_pressed_on_track()
    elseif reaper.JS_Mouse_GetState(1) == 0 and leftClick then
        -----------------------------------
        --[		  Removing Items		 ]--
        -----------------------------------
        -- If RMB first time...
        -- Flag rightClick, prevent UI refresh, set time selection start
        handle_left_mouse_released_on_track()
    elseif reaper.JS_Mouse_GetState(-1) == 2 and not rightClick then
        -- If RMB drag...
        -- Prevent that refresh, end the time selection, remove the items
        -- on curTrack, reset rightClick flag
        handle_right_mouse_pressed_on_track()
    elseif reaper.JS_Mouse_GetState(-1) == 0 and rightClick then
        handle_right_mouse_released_on_track()
    end
end

-----------------------------------
--[			  					]--
--[			   MAIN				]--
--[								]--
-----------------------------------

function main()
    --dbg(mouseDownContext, true)
    reaper.Undo_BeginBlock()
    window, segment, details = reaper.BR_GetMouseCursorContext()
    patternClipHover = hovering_over_pattern()

    -- If the user is hovering over a pattern clip
    --
    if segment == "track" and patternClipHover then
        handle_pattern_left_click()
    elseif window == "unknown" then
        handle_unknown_window_click()
    elseif reaper.JS_Mouse_GetState(1) == 0 and patternLeftClick then
        handle_release_pattern_left_drag()
    elseif reaper.JS_Mouse_GetState(-1) >= 4 then
        -----------------------------------
        -----------------------------------
        --[			Sample Load			]--
        -----------------------------------
        -----------------------------------
        -- if the user drags onto the tcp
        reaper.JS_WindowMessage_ReleaseAll()
    elseif window == "tcp" then
        handle_drag_to_tcp()
    elseif segment == "track" then
        handle_cursor_on_track()
    elseif segment ~= "track" then
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
