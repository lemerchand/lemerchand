---
--- TODO: 
---
--- 	- If no note is selected, have script target note under mouse
---
---
SCRIPT_PATH = reaper.GetResourcePath() .. "\\Scripts\\Mein\\ml"
local ml = require("ml")

reaper.Undo_BeginBlock2(0)

c = 0

function main()

	local d = ml.mwDirection()

	if d == 1 then
		reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(),40446)
	elseif d == -1 then
		reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 40447)
	end

	c = c + 1
	if c < 6 then reaper.defer(main)
	end
end

main()

reaper.Undo_EndBlock2(0, "Midi Note Length via Mousewheel", 0)
