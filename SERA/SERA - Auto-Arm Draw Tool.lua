-----------------------------------
--- SCRIPT STATE
-----------------------------------

local SERA_DRAW_COMMAND_ID = reaper.NamedCommandLookup("_RS038a6e6902fc58765c054f947aba1262f5c094e7")
local is_new_value, filename, section_ID, cmd_ID, mode, resolution, val = reaper.get_action_context()

local state = {
    currently_drawing = false
}

-----------------------------------
--- SETUP/TEARDOWN HANDLERS
-----------------------------------

local function init()
    -- Arm toolbar button
    reaper.SetToggleCommandState(section_ID, cmd_ID, 1)
    reaper.RefreshToolbar2(section_ID, cmd_ID)
end

-- TODO: Should we also force-quit the Draw Tool if it's active here?
-- Stopping the Auto-Arm script with the Draw tool enabled can lead to some funky states
local function on_exit()
    -- Set toolbar button to off
    reaper.SetToggleCommandState(section_ID, cmd_ID, 0)
    reaper.RefreshToolbar2(section_ID, cmd_ID)
end

-----------------------------------
--- HELPER FUNCTIONS
-----------------------------------

local function set_draw_command_state(toggle_state)
    -- If the desired toggle state is "on", then we need to run "SERA - Draw Tool.lua"
    if toggle_state == 1 then
        reaper.Main_OnCommand(SERA_DRAW_COMMAND_ID, 0)
    end
    -- Update the toolbar and the current state of the draw tool
    reaper.SetToggleCommandState(0, SERA_DRAW_COMMAND_ID, toggle_state)
    reaper.RefreshToolbar2(0, SERA_DRAW_COMMAND_ID)
    state.currently_drawing = reaper.GetToggleCommandState(SERA_DRAW_COMMAND_ID)
end

-----------------------------------
--- MAIN
-----------------------------------

local function main()
    reaper.PreventUIRefresh(1)

    local window, segment, details = reaper.BR_GetMouseCursorContext()
    state.currently_drawing = reaper.GetToggleCommandState(SERA_DRAW_COMMAND_ID)

    if segment == "track" then
        local track = reaper.BR_GetMouseCursorContext_Track()
        if track then
            local parent_track = reaper.GetParentTrack(track)
            -- If it doesn't have a parent track, it obviously can't belong to a SEQ pattern
            if parent_track == nil then
                -- Toggle off drawing
                if state.currently_drawing == 1 then
                    set_draw_command_state(0)
                end
            end
            -- If it does have a parent track
            if parent_track ~= nil then
                -- And the parent track is a "SEQ" track
                retval, parent_track_name = reaper.GetTrackName(parent_track)
                if parent_track_name:find("SEQ") ~= nil then
                    -- Toggle Draw tool, track that we're now drawing
                    if state.currently_drawing == 0 then
                        set_draw_command_state(1)
                    end
                end
            end
        end
    end

    -- On ESC, shut off the script
    if reaper.JS_VKeys_GetState(-1):byte(27) == 1 then
        reaper.atexit(on_exit)
        return
    else
        reaper.defer(main)
    end

    reaper.PreventUIRefresh(-1)
end

-----------------------------------
--- INVOKE
-----------------------------------

init()
main()
reaper.atexit(on_exit)
