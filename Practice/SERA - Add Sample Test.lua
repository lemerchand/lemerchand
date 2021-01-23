
local tIntercepts = {}

function reset_intercepts()
	tIntercepts = {
		WM_LBUTTONDOWN = false,
		WM_LBUTTONUP = false,
		WM_RBUTTONDOWN = false,
		WM_RBUTTONUP = false,
		WM_MOUSEMOVE = false,
		WM_SETCURSOR = false
	}
end

reset_intercepts()


-- Degbug
reaper.ClearConsole()
function dbg(txt, clear)
	if clear then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(txt))
end

-- Mouse interceptions
function intercept_mouse(tInntercepts)
	midiview = reaper.JS_Window_FromPoint(reaper.GetMousePosition())
	for key, value in pairs(tIntercepts) do
		OK = reaper.JS_WindowMessage_Intercept(midiview, key, value)
	end
end

function main()
	
intercept_mouse()
	local window, segment, details = reaper.BR_GetMouseCursorContext()
	if reaper.JS_Mouse_GetState(-1) == 0 and window == 'tcp' then 

		reaper.PreventUIRefresh(1)
		reaper.Main_OnCommand(reaper.NamedCommandLookup('_BR_SEL_TCP_TRACK_MOUSE'), 0)
		
		local p1 = 'RS5K'
		local p2 = 'ReasamplOmatic5000 (Cockos)'

		
		local fxCount =reaper.TrackFX_GetCount(reaper.GetSelectedTrack(0, 0))

		for i = 0, fxCount -1 do
			local ret, fx = reaper.TrackFX_GetFXName(reaper.GetSelectedTrack(0, 0), i, '')
			if fx:find(p1) or fx:find(p2) then

		
			reaper.TrackFX_Show( reaper.GetSelectedTrack(0, 0), i, 3 )

			
			me = reaper.JS_Window_Find("Media Explorer", true)
			reaper.JS_WindowMessage_Send(me, "WM_COMMAND", 42121, 0, 0, 0)
			reaper.TrackFX_Show( reaper.GetSelectedTrack(0, 0), i, 2 )
			break
		end
		end
		reaper.PreventUIRefresh(-1)
		reaper.JS_WindowMessage_ReleaseAll()
		return
	end

	if reaper.JS_VKeys_GetState(-1):byte(27) == 1 then 
		reaper.JS_WindowMessage_ReleaseAll()
		return  
	else reaper.defer(main) end
end
main()