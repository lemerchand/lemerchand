function not_implemented()
	reaper.ShowMessageBox('This feature has yet to be implemented', 'Message', 0)
end

function db(txt, page)
	if txt == 'before' then reaper.ClearConsole() end
	cons(txt)
	cons('\n--------\n\n')
	if debug then

		cons('\nTotal Elements: ' .. #Elements)
		cons("\nGroup Count: " .. #groups)
		
		for i, b in ipairs(groups) do
		cons('\n\t' .. i .. ". " .. b.txt .. ' - Page: ' .. b.page)

		end

		cons("\n\nBookmark Count: " .. #bookmarks)
		for i, b in ipairs(bookmarks) do
			cons('\n\t' .. i .. '. ' .. b.name)
			for ii, bb in ipairs(b.groups) do
		cons('\n\t' .. i .. ". " .. b.txt .. ' - ' .. bb)
			end
		end
	end


	cons('\n--------\n')

end