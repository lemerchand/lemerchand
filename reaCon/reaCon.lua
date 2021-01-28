function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('functions.lua')
reaperDoFile('contexts.lua')
reaper.ClearConsole()

-- Window Init
local winwidth, winheight = 450, 400


windwidth, winheight = load_window_settings()

local mousex, mousey = reaper.GetMousePosition()
gfx.init("ReaCon", winwidth, winheight, false, mousex+50,mousey-200)
local win = reaper.JS_Window_Find("ReaCon", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

----------------------------
--UI Colors-------------
----------------------------

default = {r=.7, g=.7, b=.7}
white = {r=.8, g=.8, b=.8}
red = {r=.7, g=.1, b=.2}
green = {r=.2, g=.65, b=.11}
blue = {r=.25, g=.5, b=.9}
grey = {r=.41, g=.4, b=.37}
yellow = {r=.75, g=.7, b=.3}
something = {r=.65, g=.25, b=.35}
-----------------------------------


-----------------------------------
--[		Create CLI Object		]--
-----------------------------------

c = CLI:Create()

c.history = load_file_into_table('history.dat')
if not c.history then c.history = {} end

-----------------------------------
--[				UI				]--
-----------------------------------
mainFrame = Frame:Create(nil, nil, nil, nil)
cmd = TextField:Create(nil, nil, nil, nil, '', true, false)
display = Display:Create(nil, nil, nil, nil)
display2 = Display:Create(nil, nil, nil, nil)

update_ui()
update_display()
-----------------------------------

-----------------------------------
--[			Variables			]--
-----------------------------------
local exitOnCommand = false
local refreshRate = 5

-----------------------------------
--[			MAIN				]--
-----------------------------------

function main()
	-- Draw the UI
	fill_background()
	draw_elements()


	-- Handdle keyboard input
	local char = gfx.getchar()
	-- Exit on ESC
	if char == 27 or exitOnCommand then 
		reaper.atexit(exit)
		return
	-- Otherwise, handle input and defer 
	else

		-- if "/" then activate cmd
		if char == 47 
			and cmd.active == false then cmd.active = true 
		elseif gfx.mouse_cap == 5 then dbg()
		--Undo/redo
		elseif char == 26 
			and gfx.mouse_cap == 12 then 
				reaper.Main_OnCommand(40030, 0)
		elseif char == 26 
			then reaper.Main_OnCommand(40029, 0)
		
		-- if ctrl+backspace or the user clears out the cmd then clear text
		elseif (char == 8 and gfx.mouse_cap == 04) 
			or (cmd.cpos <=0 and c.engaged) then 
				cmd.txt = ""
				c:Reset()
		--if up arrow
		elseif char == 30064 then 
			c:PrevCLI()
		--if down arrow	
		elseif char == 1685026670 then
			c:NextCLI()
		elseif char ~= 0 then --user is typing
			--if the user presses ctrl+enter then exit after commit
			if gfx.mouse_cap == 04 
				and char == 13 then 
					exitOnCommand = true
			end

			-- Send characters to the textfield
			cmd:Change(char)
			-- Parse the CLI
			c:Parse(cmd.txt)
			c:update_cli()
			update_display()
			--dbg(true)
			log(cmd.cpos)
		
		end
		
		reaper.defer(main)
	end

	-- Handle UI refresh
	refreshRate = refresh(refreshRate)
	if reaper.JS_Window_GetFocus() == win then 
		reaper.JS_Window_SetOpacity( win, 'ALPHA',  1) 

	else
		reaper.JS_Window_SetOpacity(win, 'ALPHA', .84)
		refreshRate = 50
	end
end
main()
reaper.Undo_EndBlock('ReaCon Trials', -1)