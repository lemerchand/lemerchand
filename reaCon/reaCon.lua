function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('functions.lua')

reaper.ClearConsole()

-- Window Init
local winwidth, winheight = 450, 400
local refreshRate = 5

local mousex, mousey = reaper.GetMousePosition()
gfx.init("ReaCon", winwidth, winheight, false, mousex+50,mousey-200)
local win = reaper.JS_Window_Find("ReaCon", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

----------------------------
--UI Colors-------------
----------------------------

local default = {r=.7, g=.7, b=.7}
local white = {r=.8, g=.8, b=.8}
local red = {r=.7, g=.1, b=.2}
local green = {r=.2, g=.65, b=.11}
local blue = {r=.25, g=.5, b=.9}
local grey = {r=.41, g=.4, b=.37}
local yellow = {r=.75, g=.7, b=.3}
local something = {r=.65, g=.25, b=.35}

-----------------------------------

c = CLI:Create()

-----------------------------------
--[				UI				]--
-----------------------------------
mainFrame = Frame:Create(nil, nil, nil, nil)
cmd = TextField:Create(nil, nil, nil, nil, '', true, false)
display = Display:Create(nil, nil, nil, nil)
display2 = Display:Create(nil, nil, nil, nil)

update_ui()
--------------------------------

-----------------------------------
--[			Variables			]--
-----------------------------------
local exitOnCommand = false



-----------------------------------
--[			Functions			]--
-----------------------------------
function update_display()
	display:ClearLines()
	if c.prefix then display:AddLine('Prefix: ' .. c.prefix) end
	if c.trackStr then display:AddLine('Tracks: ' .. c.trackStr) end
	if c.args then display:AddLine('Args: ' .. c.args) end
	if c.rop then display:AddLine('ROP: ' .. c.rop) end
	if c.routing then display:AddLine('Routing ' .. c.routing) end

end



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
		
		--Undo/redo
		elseif char == 26 
			and gfx.mouse_cap == 12 then 
				reaper.Main_OnCommand(40030, 0)
		elseif char == 26 
			then reaper.Main_OnCommand(40029, 0)
		
		-- if ctrl+backspace or the user clears out the cmd then clear text
		elseif (char == 8 
			and gfx.mouse_cap == 04) then 
				cmd.txt = ""
		
		--if up arrow
		elseif char == 30064 then 
			
			
		--if down arrow	
		elseif char == 1685026670 then

			else --user is typing
				--if the user presses ctrl+enter then exit after commit
				if gfx.mouse_cap == 04 
					and char == 13 then 
						exitOnCommand = true

				end

				-- Send characters to the textfield
				cmd:Change(char)
				--update_cmd(char)
				-- Parse the CLI
				c:Parse(cmd.txt)
				update_display()
		end
		

		reaper.defer(main)
	end
	--



	-- Handle UI refresh
	refreshRate = refresh(refreshRate)
end
main()