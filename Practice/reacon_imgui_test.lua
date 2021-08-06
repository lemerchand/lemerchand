local function log(str)
    reaper.ShowConsoleMsg('\n' .. tostring(str))
end

local ctx = reaper.ImGui_CreateContext("Reacon")

local function init()
    reaper.ImGui_SetNextWindowSize(ctx, 600, 300)
end

local display = ""
local input = {
    text = "",
    flags = reaper.ImGui_InputTextFlags_EnterReturnsTrue()
}

local function draw()
    local rv, changed
    reaper.ImGui_PushItemWidth(ctx, reaper.ImGui_GetWindowWidth(ctx) - 16)
    rv, display = reaper.ImGui_InputTextMultiline(
	    ctx, "##display", display
    )
    changed, input.text = reaper.ImGui_InputText(
	    ctx, "##input", input.text, input.flags, nil
    )
    reaper.ImGui_PopItemWidth(ctx)


    if changed then
	display = input.text
	input.text = ''
    end
    reaper.ImGui_End(ctx)
end

local function main()
    local visible, running = reaper.ImGui_Begin(ctx, "Reacon", true)

    if visible then draw() end

    if running then reaper.defer(main)
    else reaper.ImGui_DestroyContext(ctx)
    end
end

init()
main()
