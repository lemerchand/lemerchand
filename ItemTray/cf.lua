
function cons(text, p)
	if p == true then reaper.ClearConsole() end
	reaper.ShowConsoleMsg('\n' .. tostring(text))
end

function get_open_MEWS()
	 local retval, list = reaper.JS_MIDIEditor_ListAll()
	 local parsedlist = {}
	 
	 while true do
	 	local t = list:match('%w*')
	 	table.insert(parsedlist, reaper.JS_Window_HandleFromAddress( t ))
	 	list = list:gsub(t .. ',?', '')
	 	if list == '' then break end
	 end
	 return parsedlist
end

function missing_item(b, i)

	reaper.MB('The pinned item '.. b.name .. ' has been glued,\ndeleted, or dissapeared into the ether.\n\nTip: Repin items after gluing.' , 'Something\'s amiss', 0)
	b:Remove(false, i)	

end