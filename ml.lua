local ml = {}

function ml.cons(m,p)
	--Outputs a message, m, to the console. p = 0 for new line, p=1 to and output---

	if p == 1 then
		reaper.ClearConsole()
	end

	reaper.ShowConsoleMsg((m .. "\n"))
end


function ml.mwDirection()
	---Detects the direction fo the mousewheel and returns 1 or -1 for Up or Down respectvely---

	local is_new_value, filename, sectionID, cmdID, mode, resolution, mw = reaper.get_action_context()
	if mw > 1 then
		--ml.cons(mw, 0)
		return 1
	elseif mw < 0 then
		--ml.cons(mw, 0)
		return -1
	else
		return 0
	end
end


--------------------------
---Return entire library--
--------------------------
return ml


---eat a fat fucking dick