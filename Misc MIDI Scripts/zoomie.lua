local window, segment, details = reaper.BR_GetMouseCursorContext()
local starting_start_time, starting_end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0)

local starting_mousex, starting_mousey = reaper.GetMousePosition()


local starting_mouse_update = .5

gfx.init("lil zoomie", 300,100, false, starting_mousex+105, starting_mousey-50 )



local keypressed = reaper.time_precise()
local keyreleased = 0
local key = 282
local mouse_moved = 0


function main()

	local mousex, mousey = reaper.GetMousePosition()
	local mousex_proj = reaper.BR_GetMouseCursorContext_Position()
	local start_time, end_time = reaper.GetSet_ArrangeView2( 0, false, 0, 0)

	local key = gfx.getchar()
	
	if  mouse_moved > starting_mouse_update and mousex_proj < end_time-5 then
		starting_mousex, starting_mousey = reaper.GetMousePosition()
		mouse_moved = 0
	end


	if mousex > starting_mousex+10 then 
		dif_mousex_start = mousex_proj - start_time
		dif_mousex_end = end_time - mousex_proj
		reaper.GetSet_ArrangeView2(0, true, 0, 0, start_time+(dif_mousex_start*.05), end_time-(dif_mousex_end*.05))
		mouse_moved = reaper.time_precise()-keypressed

	elseif mousex < starting_mousex-10 then
		dif_mousex_start = mousex_proj - start_time
		dif_mousex_end = end_time - mousex_proj
		reaper.GetSet_ArrangeView2(0, true, 0, 0, start_time-(dif_mousex_start*.05), end_time+(dif_mousex_end*.05))
		mouse_moved = reaper.time_precise()-keypressed
	end


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
	gfx.drawstr("\n_mousex proj: " .. mousex_proj)

	reaper.defer(main)
	
end

main()

