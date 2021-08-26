---@diagnostic disable: lowercase-global
-- @version 0.3.3
-- @author Lemerchand
-- @about A REAPER command line
-- @provides
--    [main] .
--    [nomain] ui.lua
--    [nomain] functions.lua
--    [nomain] contexts.lua
-- @changelog
--    + Began working on tracknotes 

function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('ui.lua')
reaperDoFile('functions.lua')
reaperDoFile('contexts.lua')
reaper.ClearConsole()

-- Window Init
local winwidth, winheight = 450, 400
local wasUnfocused = false

winwidth, winheight = load_window_settings()
local mousex, mousey = reaper.GetMousePosition()
gfx.init("ReaCon", winwidth, winheight, false, mousex+50,mousey-200)
local win = reaper.JS_Window_Find("ReaCon", true)
if win then reaper.JS_Window_AttachTopmostPin(win) end

----------------------------
--UI Colors--------------
----------------------------

default = {r=.75, g=.75, b=.75}
white = {r=.95, g=.95, b=.95}
red = {r=.7, g=.1, b=.2}
orange = {r=1, g=.6, b=0}
yellow = {r=.75, g=.7, b=.3}
green = {r=.2, g=.65, b=.11}
blue = {r=.25, g=.5, b=.9}
violet = {r=.5, g=.1, b=.7}
grey = {r=.41, g=.4, b=.4}
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

-- Regular display
cmd = TextField:Create(nil, nil, nil, nil, '', true, false)
display = Display:Create(nil, nil, nil, nil)
display2 = Display:Create(nil, nil, nil, nil)


-- Inspection display
btn_editNotes = Button:Create(nil, nil,'Edit Notes')
btn_editNotes.hide = true
btn_editNotes.border = false

btn_cancel = Button:Create(nil, nil, 'Cancel')
btn_cancel.hide = true
btn_cancel.border = false

-- Text editor display
editor = TextEditor:Create(nil, nil, nil, nil, '', false)
editor.hide = true

update_ui()
update_display()
-----------------------------------

-----------------------------------
--[			Variables			]--
-----------------------------------
local exitOnCommand = false
local refreshRate = 10

-----------------------------------
--[			MAIN				]--
-----------------------------------

function main()
    -- Draw the UI
    --fill_background()
    gfx.clear = 3092271
    draw_elements()

    -- Handle alternate views
    if c.context == 'TEXTEDITOR' then 
	text_editor_display()
	if btn_editNotes.leftClick  then
	    save_track_notes(reaper.GetSelectedTrack(0, 0))
	    c.context = 'SELECTTRACKS'
	elseif btn_cancel.leftClick then 
	    c.subcontext = 'NONE'
	    c.context = 'SELECTTRACKS'

	end
    end

    -- Handle button clicks
    if btn_editNotes.leftClick and c.subcontext == 'INSPECTTRACK' then
	local track = reaper.GetSelectedTrack(0, 0)
	local ret, trackName = reaper.GetTrackName(track)
	load_track_notes(track)
	c.context = 'TEXTEDITOR'
	c.subcontext = '**yTrack Notes: ** '.. trackName
    end

    -- Handdle keyboard input
    local char = gfx.getchar()
    -- Exit on ESC
    if exitOnCommand then 
	reaper.atexit(exit)
	return
    elseif cmd.txt:find('/ns') then
	reaper.atexit(exitnosave)

	-- Otherwise, handle input and defer 
    else

	-- If the text editor is active then it steals keystrokes
	if editor.active then 
	    editor:Change(char)


	    -- if "/" then activate cmd
	elseif char == 47 
	    and cmd.active == false then cmd.active = true 
	    --Undo/redo
	elseif char == 26 
	    and gfx.mouse_cap == 12 then 
	    reaper.Main_OnCommand(40030, 0)
	elseif char == 26 
	    then reaper.Main_OnCommand(40029, 0)

	    -- if ctrl+backspace or the user clears out the cmd then clear text
	elseif (char == 8 and gfx.mouse_cap == 04) 
	    or (cmd.cpos < 0 and c.engaged) then 
	    cmd.txt = ""
	    c:Reset()
	    --if up arrow
	elseif char == 30064 then 
	    c:PrevCLI()
	    --if down arrow	
	elseif char == 1685026670 then
	    c:NextCLI()

	elseif cmd.txt:find('/dbg') then
	    cmd.txt = cmd.txt:gsub('/dbg', '')
	    cmd.cpos = string.len(cmd.txt)
	    dbg(false)


	elseif char ~= 0 then --user is typing
	    if not reaper.JS_Window_Find( 'ReaCon', true ) then 
		reaper.atexit(exit)
	    return end


	    --if the user presses ctrl+enter then exit after commit
	    if gfx.mouse_cap == 04 
		and char == 13 then 
		exitOnCommand = true
	    elseif char == 8 and cmd.cpos <= 1 then
		c:Reset()
	    end

	    -- Send characters to the textfield
	    cmd:Change(char)
	    -- Parse the CLI
	    c:Parse(cmd.txt)
	    c:update_cli()
	    update_display()
	    -- dbg(true)
	    --log(c.context)
	    

	end
	if cmd.leftClick then cmd.active = true end
	reaper.defer(main)
    end

    -- Handle UI refresh
    refreshRate = refresh(refreshRate)
    if reaper.JS_Window_GetFocus() == win then
	if wasUnfocused then 
	    reaper.JS_Window_SetOpacity( win, 'ALPHA',  1) 
	    wasUnfocused = false
	end
    else
	reaper.JS_Window_SetOpacity(win, 'ALPHA', .84)
	refreshRate = 50
	wasUnfocused = true
    end
end
main()
reaper.atexit(exit)
reaper.Undo_EndBlock('ReaCon Trials', -1)
