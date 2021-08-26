local r = reaper

local function log(str)
    r.ShowConsoleMsg('\n' .. tostring(str))
end

local ctx = r.ImGui_CreateContext("Reacon")

local function init()
    r.ImGui_SetNextWindowSize(ctx, 600, 300)
end

local display = ""
local input = {
    text = "",
    flags = r.ImGui_InputTextFlags_EnterReturnsTrue()
}

local function display()	
    r.ImGui_BeginTable(ctx, "display", 5)	
    r.ImGui_TableSetupColumn(ctx, '1')
    r.ImGui_TableSetupColumn(ctx, '2')
    r.ImGui_TableSetupColumn(ctx, '3')
    r.ImGui_TableSetupColumn(ctx, '4')
    r.ImGui_TableSetupColumn(ctx, '5')
    r.ImGui_TableHeadersRow(ctx)

    r.ImGui_TableNextRow(ctx) ; r.ImGui_TableSetColumnIndex(ctx, 0) ; r.ImGui_TextColored(ctx, 0xFF00FFFF, 'Ho') 
    r.ImGui_TableNextRow(ctx) ; r.ImGui_TableSetColumnIndex(ctx, 0) ; r.ImGui_Text(ctx, 'Ho') 
    r.ImGui_TableNextRow(ctx) ; r.ImGui_TableSetColumnIndex(ctx, 0) ; r.ImGui_Text(ctx, 'Ho') 
    r.ImGui_TableNextRow(ctx) ; r.ImGui_TableSetColumnIndex(ctx, 0) ; r.ImGui_Text(ctx, 'Ho') 
    r.ImGui_TableNextRow(ctx) ; r.ImGui_TableSetColumnIndex(ctx, 0) ; r.ImGui_Text(ctx, 'Ho') 

    r.ImGui_EndTable(ctx)
end

local function main()
    local rv, entered
    r.ImGui_PushItemWidth(ctx, r.ImGui_GetWindowWidth(ctx) - 16)
    display()
    entered, input.text = r.ImGui_InputText(
    ctx, "##input", input.text, input.flags
    )
    r.ImGui_PopItemWidth(ctx)

    if entered then
	display = input.text
	input.text = ''
    end
    r.ImGui_End(ctx)
end

local function loop()
    local visible, running = r.ImGui_Begin(ctx, "Reacon", true)

    if visible then main() end

    if running then r.defer(loop)
    else r.ImGui_DestroyContext(ctx)
    end
end

init()
loop()
