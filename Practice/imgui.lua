function reaperDoFile(file)
    local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); 
end
reaperDoFile('ui.lua')

winwidth, winheight = 500, 250
local mousex, mousey = reaper.GetMousePosition()
gfx.init("reavim", winwidth, winheight, false, mousex+50,mousey-200)
local win = reaper.JS_Window_Find("reavim", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end




function main()
	-- Draw the UI
	--fill_background()
	gfx.clear = 3092271
	draw_elements()


  end
