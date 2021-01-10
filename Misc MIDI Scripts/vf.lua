function not_implemented()
	reaper.ShowMessageBox('This feature has yet to be implemented', 'Message', 0)
end

function debug(txt)

	cons(txt)
	cons('\n--------\n\n')
	if debug then
		cons('\nTotal Elements: ' .. #Elements)
		cons("\nGroup Count: " .. #groups)
		
		for i, b in ipairs(groups) do
		cons('\n\t' .. i .. ". " .. b.txt)
		end

		cons("\n\nBookmark Count: " .. #bookmarks)
		for i, b in ipairs(bookmarks) do
			cons('\n\t' .. i .. '. ' .. b.name)
			for ii, bb in ipairs(b.groups) do
				cons('\n\t\tgroup: index= ' .. ii .. ' group= ' .. bb .. '\n')
			end
		end
	end

	cons('\n' .. txt)
	cons('\n--------\n')

end