local SERA_DRAW_COMMAND_ID = reaper.NamedCommandLookup("_RS038a6e6902fc58765c054f947aba1262f5c094e7")
is_new_value, filename, section_ID, cmd_ID, mode, resolution, val = reaper.get_action_context()

state = {
    currently_drawing = false
}

function init()
    -- Arm toolbar button
    reaper.SetToggleCommandState(section_ID, cmd_ID, 1)
    reaper.RefreshToolbar2(section_ID, cmd_ID)
end

function on_exit()
    -- Set toolbar button to off
    reaper.SetToggleCommandState(section_ID, cmd_ID, 0)
    reaper.RefreshToolbar2(section_ID, cmd_ID)
end

function opposite_drawing_state()
    currently_drawing = reaper.GetToggleCommandState(SERA_DRAW_COMMAND_ID)
    if currently_drawing == 0 then
        return 1
    elseif currently_drawing == 1 then
        return 0
    end
end

function set_draw_command_state(state)
    reaper.Main_OnCommand(SERA_DRAW_COMMAND_ID, 0)
    reaper.SetToggleCommandState(0, SERA_DRAW_COMMAND_ID, state)
    reaper.RefreshToolbar2(0, SERA_DRAW_COMMAND_ID)
end

function main()
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
                set_draw_command_state(0)
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

    if reaper.JS_VKeys_GetState(-1):byte(27) == 1 then
        reaper.atexit(on_exit)
        return
    else
        reaper.defer(main)
    end

    reaper.PreventUIRefresh(-1)
end

init()
main()
reaper.atexit(on_exit)
