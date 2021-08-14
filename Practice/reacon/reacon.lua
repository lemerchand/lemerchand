-- ___ ___   _   ___ ___  _  _
--| _ \ __| /_\ / __/ _ \| \| |
--|   / _| / _ \ (_| (_) | .` |
--|_|_\___/_/ \_\___\___/|_|\_|
---------------------------------
--
--
--
--
--           __
--  ___ ___ / /___ _____
-- (_-</ -_) __/ // / _ \
--/___/\__/\__/\_,_/ .__/
--                /_/
----------------------------------

local r = reaper
local script = {
    name='reacon',
    version = '.01',
    path = '',
    width = 500,
    height = 400
}

local PAD = {X=16, Y=28}

function rDoFile(file)
    local info = debug.getinfo(1,'S');
    script.path = info.source:match[[^@?(.*[\/])[^\/]-$]]
    dofile(script.path .. file)
end

rDoFile('libs/common_functions.lua')
rDoFile('libs/ui.lua')

ctx = r.ImGui_CreateContext(script.name)
r.ImGui_SetNextWindowSize(ctx, script.width, script.height)

local txt_display = TextDisplay( 'txt_display', 'Tonka')
local prompt = InputBox('prompt','')

--  __ _  ___ _(_)__
-- /  ' \/ _ `/ / _ \
--/_/_/_/\_,_/_/_//_/
--
--TODO:
-- * See how to go about making a text display via classes
-- * Left off just before making the Draw() method

local function main()
    r.ImGui_PushItemWidth(ctx, r.ImGui_GetWindowWidth(ctx) - PAD.X)
    local posy = r.ImGui_GetWindowHeight(ctx) - PAD.Y
    r.ImGui_SetCursorPosY(ctx, posy)
    prompt:Draw()
    r.ImGui_SetCursorPosY(ctx, PAD.Y)
    txt_display.height = posy - (1.25 * PAD.Y)
    txt_display:Draw()
    r.ImGui_PopItemWidth(ctx)

    r.ImGui_End(ctx)
end


--   __
--  / /__  ___  ___
-- / / _ \/ _ \/ _ \
--/_/\___/\___/ .__/
--           /_/
local function loop()
    local visible, running = r.ImGui_Begin(ctx, "Reacon", true)

    if visible then main() end

    if running then r.defer(loop)
    else r.ImGui_DestroyContext(ctx)


    end
end

loop()

