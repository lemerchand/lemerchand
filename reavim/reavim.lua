reaper.ClearConsole()
local start_time = reaper.time_precise()
local last_focused =  reaper.JS_Window_GetFocus()


function reaperDoFile(file)
    local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); 
end
reaperDoFile('ui.lua')

winwidth, winheight = 1, 1
local mousex, mousey = reaper.GetMousePosition()
gfx.init("reavim", winwidth, winheight, false, 1, 1)
local win = reaper.JS_Window_Find("reavim", true)
-- if win then reaper.JS_Window_AttachTopmostPin(win) end


local dbg = true
local timeout = .135
local kb = {
    main = {},
    midi = {}
}

function con(str)
    reaper.ShowConsoleMsg('\n' .. tostring(str))
end

con(reaper.JS_Window_GetTitle(last_focused))
function default_settings()
    file = io.open(script_path ..'settings.conf', 'w')
    file:close()
end

function default_keybindings()
    file = io.open(script_path .. cmd .. '-kbs.conf', 'w')
    file:close()
end

function load_settings()
    local file = io.open(script_path ..'settings.conf', 'r')
    if file == nil then
        default_settings()
        file = io.open(script_path ..'settings.conf', 'r') 
    end
end

function load_keybindings()
    local file = io.open(script_path .. cmd .. '-kbs.conf', 'r')
    if file == nil then
        default_keybindings()
        file = io.open(script_path .. cmd .. '-kbs.conf', 'r' )
    end

    for line in file:lines() do
        if line == nil then break end
        if line:sub(1, 2) == '--' 
        or line:sub(1,1) == '' then goto pass end
        local context = line:sub(1, line:find(' ')-1)
        line = line:gsub(context .. ' ', '')
        local key = line:sub(1, line:find(' ')-1)
        cmds = line:gsub(key .. ' ', '')
        local temp_cmds = {}
        for c in cmds:gmatch('[^%s]+') do
            table.insert(temp_cmds, c)
        end
        if context == 'main:' then 
            table.insert(kb.main, {key, {temp_cmds}})
        elseif context == 'midi:' then 
            table.insert(kb.midi, {key, {temp_cmds}})
        end
        ::pass::
    end
    file:close()
end

function ex_commands(cmds)
    for i, cmd in ipairs(cmds) do
        if cmd:sub(1,1) == 'm' then 
            local midi = true
            cmd = cmd:sub(2)
        end
        if type(cmd) == "string" then 
            cmd = reaper.NamedCommandLookup(cmd)
        end
        if midi then 
            reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive, cmd)
        else
            reaper.Main_OnCommand(cmd, 0)
        end

    end
end

function check_cmds(q)
    lf_str = reaper.JS_Window_GetTitle(last_focused)
    if lf_str == 'trackview' then list = kb.main 
    elseif lf_str == 'midiview' then list = kb.midi
        con('mididididid')
    end
    for k, v in pairs(kb.main) do
        con(v[1])
        if q == v[1] then ex_commands(v[2][1]) end
    end

end

function init()
    load_settings()
    load_keybindings()

end

init()

function main()
    -- Draw the UI

    gfx.clear = 3092271
    draw_elements()
    local char = gfx.getchar()
    -- local char = reaper.JS_VKeys_GetState(start_time)
    if char ~= 0 then 
        cmd = cmd .. string.char(char)
    end
    current_time = reaper.time_precise()
    if (current_time - timeout >= start_time) or char == 27 then

        check_cmds(cmd)
        reaper.atexit()
        return
    else

        reaper.defer(main)
    end   

end

