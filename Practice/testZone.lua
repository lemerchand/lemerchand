function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')


gfx.init("Lemerchand GUI Demo", 300,400, false, 1500,600)
status = Status:Create(10,10,280,350)

lastChar = 0
function main()

	fill_background()

	local char = gfx.getchar()
	if char == 27 or char == -1 then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else reaper.defer(main) end

	--Draws all elements
	draw_elements()
	if char ~= 0 then lastChar = char end
	status:Display("Mouse_cap:   " .. gfx.mouse_cap ..
				"\nChar:   " .. lastChar .. 
				"\nJS Mouse_getState: " .. reaper.JS_Mouse_GetState(-1))


	
end
main()