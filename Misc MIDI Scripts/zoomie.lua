local window, segment, details = reaper.BR_GetMouseCursorContext()
local mouse = reaper.BR_GetMouseCursorContext_Position()
reaper.ShowConsoleMsg("\nx: " .. mouse)

local start_time, end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0)
local total_time = start_time + end_time
local dif_mousend = end_time - mouse
local dif_mousestart = mouse - start_time

reaper.GetSet_ArrangeView2(0, true, 0, 0, start_time+(dif_mousestart/2), end_time-(dif_mousend/2))