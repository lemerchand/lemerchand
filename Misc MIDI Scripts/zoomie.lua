--ONLOAD -- DOES NOT CHANGE
local window, segment, details = reaper.BR_GetMouseCursorContext()
local starting_start_time, starting_end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0)
local starting_mousex, starting_mousey = reaper.GetMousePosition()
local starting_mousex_proj_time = reaper.BR_GetMouseCursorContext_Position()


gfx.init("lil zoomie", 300,100, false, starting_mousex+105, starting_mousey-50 )

--Starting settings of the arrangeview
local start_time, end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0)

local keypressed = reaper.time_precise()
local keyreleased = 0
local key = 282


function main()
	window, segment, details = reaper.BR_GetMouseCursorContext()
	local mousex, mousey = reaper.GetMousePosition()
	local mousex_proj_time = reaper.BR_GetMouseCursorContext_Position()
	local zoom_level = reaper.GetHZoomLevel()
	local current_start_time, current_end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0)

	local key = gfx.getchar()

	--Mouse position difference from script init
	local dif_mousex = ((starting_mousex - mousex))
	
	local a = ((starting_mousex_proj_time + dif_mousex)  * .5)/zoom_level
	local b = ((starting_mousex_proj_time - dif_mousex)  * .5)/zoom_level


	--set the arrangeview to the OG startime minus the diference of the mouse position vs OG
	--It needs to be offset to center arround the mouses position
	reaper.GetSet_ArrangeView2(0, true, 0, 0, a, b)
	
	
	

	-- Defer oq quit
	if key == 282 then
		keyreleased = 0
		first = false
	elseif key == 0 and keyreleased > .45 then return
	elseif key == 0 then 
		keyreleased = (reaper.time_precise() - keypressed)  
	end

	-- Display info
	gfx.x, gfx.y = 10, 10
    gfx.drawstr("\n_mouse proj time: " ..a .. "\nZoom level: " .. b)

	reaper.defer(main)
	
end

main()

