reaper.ClearConsole()
local start_time = reaper.time_precise()
local last_focused =  reaper.JS_Window_GetFocus()
local last_char = cmd

function reaperDoFile(file)
    local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); 
end

local timeout = .255
local kb = {
    main = {},
    midi = {}
}

function con(str)
    reaper.ShowConsoleMsg('\n' .. tostring(str))
end

function default_settings()
    file = io.open(script_path ..'settings.conf', 'w')
    file:close()
end

function default_keybindings()
    file = io.open(script_path .. 'confs/' .. cmd .. '-kbs.conf', 'w')
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
    local file = io.open(script_path .. 'confs/' .. cmd .. '-kbs.conf', 'r')
    if file == nil then
        default_keybindings()
        file = io.open(script_path .. 'confs/' .. cmd .. '-kbs.conf', 'r' )
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
    reaper.PreventUIRefresh(1)
    local midi = false
    for i, cmd in ipairs(cmds) do
        if cmd:sub(1,1) == 'm' then 
            midi = true
            cmd = cmd:sub(2)
        end

        if cmd:sub(1,1) == '_' then
            cmd = reaper.NamedCommandLookup(cmd)
        end

        if midi then 
            reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), cmd)
        else
            reaper.Main_OnCommand(cmd, 0)
        end
    -- con(cmd)
    end
    reaper.PreventUIRefresh(-1)
end

function check_cmds(q)
    lf_str = reaper.JS_Window_GetTitle(last_focused)
    if lf_str == 'trackview' then list = kb.main 
    elseif lf_str == 'midiview' then list = kb.midi
    else list = kb.main
    end
    for k, v in pairs(list) do
        if q == v[1] then ex_commands(v[2][1]) end
    end

end

function init()
    local intercept_level = reaper.JS_VKeys_Intercept(-1, 0)
    reaper.JS_VKeys_Intercept(-1, - intercept_level)
    load_settings()
    load_keybindings()
    reaper.JS_VKeys_Intercept(-1, 1)    

end

function onexit()
    reaper.JS_VKeys_Intercept(-1, -1)    
end

function get_char()
    local char = reaper.JS_VKeys_GetState(-1)    
    for i = 1, 255 do
        if char:byte(i) ~= 0 then 
            return i+32
        end
    end
    return nil 
end

init()

function main()
    char = get_char()
    if char == nil then  
        last_char = ''
    else
        char = string.char(char):lower() 
        if char ~= last_char then 
            cmd = cmd .. char 
            last_char = char
            timeout = timeout + .250

        end
    end

    current_time = reaper.time_precise()

    if (current_time - timeout >= start_time) or char == 27 then
        check_cmds(cmd)
        reaper.atexit(onexit)
        return
    else
        reaper.defer(main)
    end   
end

