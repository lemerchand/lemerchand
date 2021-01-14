-- @noindex
function not_implemented()
	reaper.ShowMessageBox('This feature has yet to be implemented', 'Message', 0)
end

function db(txt, page)

	cons(txt)
	cons('---------------------------\n')
	

	cons('Enable help: ' .. tostring(enableHelp))
	cons('\nTotal Elements: ' .. #Elements)
	cons("\nGroup Count: " .. #groups)
	
	for i, b in ipairs(groups) do
	cons('\t' .. i .. ". " .. b.txt .. ' - Page: ' .. b.page)

	end

	cons("\nBookmark Count: " .. #bookmarks)
	for i, b in ipairs(bookmarks) do
		cons('\t' .. i .. '. ' .. b.name)
		for ii, bb in ipairs(b.groups) do
			cons('\t\t' .. i .. ". "  .. bb)
		end
	end

	
	cons('--------------------------\n')

end

