function reaperDoFile(file)
    local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); 
end
reaperDoFile('ui.lua')

winwidth, winheight = 500, 250
local mousex, mousey = reaper.GetMousePosition()
gfx.init("reavim", winwidth, winheight, false, mousex+50,mousey-200)
local win = reaper.JS_Window_Find("reavim", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

local dbg = true
local timeout = 20
local kb = {}

function default_settings()
    file = io.open(script_path ..'settings.conf', 'w')
    file:close()
end

function default_keybindings()
    file = io.open(script_path ..'keybindings.conf', 'w')
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
    local file = io.open(script_path ..'keybindings.conf', 'r')
    if file == nil then
        default_keybindings()
        file = io.open(script_path ..'keybindings.conf', 'r') 
    end

    for line in file:lines() do
        if line == nil then break end
        local key = line:sub(1, line:find(' ')-1)
        local cmds = line:sub(line:find(' ')+1)
        local temp_cmds = {}
        for c in cmds:gmatch('[^%s]+') do
            table.insert(temp_cmds, c)
        end
        table.insert(kb, {key, {temp_cmds}})
    end
    file:close()
end

function ex_commands(cmds)
    for cmd in cmds do
        reaper.ShowConsoleMsg(cmd)
    end
end

function check_cmds(q)
    for i, cmd in ipairs(kb) do
        reaper.ShowConsoleMsg(cmd[1])
        --if q == cmd[1] then ex_commands(cmd[2]) end
    end

end

function init()
    load_settings()
    load_keybindings()

end

init()
local cmd = ''

function main()
    -- Draw the UI
    --fill_background()
    gfx.clear = 3092271
    draw_elements()
    char = gfx.getchar()
    if char ~= 0 then 
        cmd = cmd .. string.char(char)
    end
    if timeout == 0 or char == 27 then
        
        check_cmds(cmd)
        reaper.atexit()
        return
    else
        timeout = timeout - 1
        gfx.drawstr(timeout)
        reaper.defer(main)
    end   

end

main()
