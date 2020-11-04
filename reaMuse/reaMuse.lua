function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../gui.lua')
reaperDoFile('../cf.lua')


gfx.init("reaMuse", 550,160, false, 550,350)

-- Define window name so that script can stop defering when unfocused
local me = reaper.JS_Window_GetFocus()

-- Flags for text drawing
local maintainText = false
local fadeText = false
local f = .19

-- Tables of words
local verbs = {}
local nouns = {}
local pluralNouns = {}
local adjs = {}
local conjs = {}
local gerunds = {}
local locations = {}
local preps = {}
local advs = {}
local prompts = {}
local determiners = {}
local pluralDeterminers = {}
local questionCaps = {}
local pattern = {"literal", "abstract", "short", "long"}


-- Load words from files into tables
function load_words()
	--Retrieve verbss
	local verbsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/verbs.dat', 'r')


	for line in verbsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(verbs, word)
		end
	end
	verbsFile:close()

	--Retrieve  nounss
	local nounsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/nouns.dat', 'r')
	for line in nounsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(nouns, word)
		end
	end
	nounsFile:close()

	--Retrieve  plural nouns
	local pluralNounsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/pluralNouns.dat', 'r')
	for line in pluralNounsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(pluralNouns, word)
		end
	end
	pluralNounsFile:close()

	--Retrieve conjsugations
	local conjsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/conj.dat', 'r')


	for line in conjsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(conjs, word)
		end
	end
	conjsFile:close()

	--Retrieve  adjsective
	local adjsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/adjs.dat', 'r')
	for line in adjsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(adjs, word)
		end
	end
	adjsFile:close()

	--Retrieve  locationss
	local locFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/locations.dat', 'r')
	for line in locFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(locations, word)
		end
	end
	locFile:close()

	--Retrieve  prepositions
	local prepsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/preps.dat', 'r')
	for line in prepsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(preps, word)
		end
	end
	prepsFile:close()

	--Retrieve  advserbss
	local advsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/adverbs.dat', 'r')
	for line in advsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(advs, word)
		end
	end
	advsFile:close()

	--Retrieve  gerundss
	local gerundsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/gerund.dat', 'r')
	for line in gerundsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(gerunds, word)
		end
	end
	gerundsFile:close()

	--Retrieve  prompts
	local promptsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/prompts.dat', 'r')
	for line in promptsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(prompts, word)
		end
	end
	promptsFile:close()

	--Retrieve  determiners
	local determinersFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/determiners.dat', 'r')
	for line in determinersFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(determiners, word)
		end
	end
	determinersFile:close()

	local pluralDeterminersFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/pluralDeterminers.dat', 'r')
	for line in pluralDeterminersFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(pluralDeterminers, word)
		end
	end
	pluralDeterminersFile:close()

	-- Load question caps
	local questionCapsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/questionCaps.dat', 'r')
	for line in questionCapsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(questionCaps, word)
		end
	end
	questionCapsFile:close()


end



-- Randomly generate a new sentence
function new_message()

	local sentence = ""
	local noun = ""
	local determiner = ""

	-- Determine plural or singluar
	if math.random(1,100) <=50 then 
		noun = nouns[math.random(1, count_table(nouns))]
		determiner = determiners[math.random(1, count_table(determiners))]
		local plural = false
	else
		noun = pluralNouns[math.random(1, count_table(pluralNouns))]
		determiner = pluralDeterminers[math.random(1, count_table(pluralDeterminers))]
		local plural = true
	end

	-- Generate random fragments
	local prompt 	= prompts[math.random(1, count_table(prompts))]
	local verb 		= verbs[math.random(1, count_table(verbs))]
	local prep 		= preps[math.random(1, count_table(preps))]
	local location 	= locations[math.random(1, count_table(locations))]
	local adj 		= adjs[math.random(1, count_table(adjs))]
	local adv 		= advs[math.random(1, count_table(advs))]
	local gerund 	= gerunds[math.random(1, count_table(gerunds))]
	local conj 		= conjs[math.random(1, count_table(conjs))]	

	-- Make adjustments
	if prompt == "is" and plural then prompt = "are" end

	if (prompt == "should" or prompt == "would" or prompt == "find") and not plural then 
		noun = pluralNouns[math.random(1, count_table(pluralNouns))]
		determiner = pluralDeterminers[math.random(1, count_table(pluralDeterminers))]
		plural = true
	 end

	-- Randomly choose a pattern

	local rp = math.random(1, 4)

	if pattern[rp] == "literal" or "abstract" then 

		sentence = prompt .. " " .. gerund  .. "\n" .. determiner .. " "  ..  noun

	elseif pattern[rp] == "short" then 

		sentence = prompt .. "HAAAAAA " .. gerund

	elseif pattern[rp] == "long" then

		sentence = prompt .. " " .. adv .. "\n" .. gerund  .. " " .. determiner .. " " .. adj .. "\n" ..  noun

	end

	cons(pattern[rp], true)
	

	return sentence
end

-- Draw the sentence
function fade_text(str, x, y)
	
	gfx.setfont(5, "Lucida Console", 26)
	
	if maintainText then f = .9
	elseif f == -1 then return
	elseif f < (.9) and f > -1 then
		f = f + .01

		if f == (.9) then 
			maintainText = true
			fadeText = false
		end
	end

	gfx.set(f, f, f)
	gfx.x, gfx.y = x, y
	gfx.drawstr(str)
end

-- Load words
load_words(verbs, nouns)
-- Generate first sentence
local message = new_message()



function main()
	
	fill_background()

	-- Exit or defer the script
	local char = gfx.getchar()
	if char == 27 or char == -1 or reaper.JS_Window_GetFocus() ~= me then 
		reaper.atexit(reaper.JS_Window_SetFocus(last_window))
		return
	-- Otherwise keep window open
	else reaper.defer(main) end


	-- Display the text
	fade_text(message, 20,40)

	-- Regenerate a sentence if the gui is clicked
	if gfx.mouse_cap == 1 then
		message = new_message()
		f = .19
	end

end

main()