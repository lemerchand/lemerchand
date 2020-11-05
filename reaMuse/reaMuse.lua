function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile('../cf.lua')


gfx.init("reaMuse", 500,220, false, 550,350)

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
local altQuestionCaps = {}
local questions = {}
local pronouns = {"it", "them", "this", "yourself"}
local patterns = {"literal", "abstract", "short", "long"}


-- excludes words
local shortexcludes = {"fnding", "find", "reverse", "reversing"}
local commandexcludes = {"beneath"}
local beneathbelow_excludes = {"the community", "the front", "the back", "the chorus", 
							"the intro", "the verse", "the trash", "the measure", "the begining", "the end",
							"the verse", "another section"}

--Fills the gfx window background with color
function fill_background()
	local r, g, b, a = .19,.19,.19, 1
	local w, h = gfx.w, gfx.h

	gfx.set(r,g,b,a)
	gfx.rect(0,0,w,h,true)

end

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

	-- Load questions
	local questionsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/questions.dat', 'r')
	for line in questionsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(questions, word)
		end
	end
	questionsFile:close()

	-- Load ing question caps
	local altQuestionCapsFile = io.open(reaper.GetResourcePath() .. '/Scripts/lemerchand/reaMuse/altQuestionCaps.dat', 'r')
	for line in altQuestionCapsFile:lines() do
		local word = line
		if word == nil then break
		else 
			table.insert(altQuestionCaps, word)
		end
	end
	altQuestionCapsFile:close()

end

function replace_excludes(verb, verb2, gerund, noun, noun2, questionCap, altQuestionCap, location, question, determiner, excluded)
	local replacing = true

	while replacing do
		for i = 1, count_table(excluded) do
			if verb == excluded[i] then verb = verbs[math.random(1, count_table(verbs))] 
			elseif gerund == excluded[i] then gerund = gerund[math.random(1, count_table(gerunds))] 
			elseif noun == excluded[i] then noun = nouns[math.random(1, count_table(nouns))] 
			elseif questionCap == excluded[i] then questionCap = questionCaps[math.random(1, count_table(questionCaps))] 
			elseif altQuestionCap == excluded[i] then altQuestionCap = altQuestionCaps[math.random(1, count_table(altQuestionCaps))] 
			elseif location == excluded[i] then location = locations[math.random(1, count_table(locations))] 
			elseif questions== excluded[i] then question = questions[math.random(1, count_table(questions))] 
			elseif determiner == excluded[i] then determiner = determinersds[math.random(1, count_table(determiners))] 
			elseif verb2 == excluded[i] then verb = verbs[math.random(1, count_table(verbs))] 
			elseif noun2 == excluded[i] then verb = nouns[math.random(1, count_table(nouns))] 
			else 
				replacing = false
			end
		end
	end

end



-- Randomly generate a new sentence
function new_message()

	local sentence = ""
	local noun = ""
	local prnoun = ""
	local determiner = ""
	local isCommand = false
	local isQuestion = false
	local isSuggestion = false


	-- Determine plural or singluar
	if math.random(1,100) <=50 then 
		noun = nouns[math.random(1, count_table(nouns))]
		noun2 = nouns[math.random(1, count_table(nouns))]
		determiner = determiners[math.random(1, count_table(determiners))]
		
		local plural = false
	else
		noun = pluralNouns[math.random(1, count_table(pluralNouns))]
		noun2 = nouns[math.random(1, count_table(nouns))]
		determiner = pluralDeterminers[math.random(1, count_table(pluralDeterminers))]

		local plural = true
	end

	-- Determine question, command, or suggestion

	local sentenceType = math.random(1, 100)

	if sentenceType <= 35 then isQuestion = true 
	elseif sentenceType >=36 and sentenceType <=69 then isSuggestion = true
	else isCommand = true
	end

	-- Isolate sentence type -- FOR DEBUG

	--isCommand = true
	--isQuestion = true
	--isSuggestion = true

	-- Determine sentence pattern
	local rp = math.random(1, 4)
	local pattern = patterns[rp]

	-- Generate random fragments
	local prompt 			= prompts[math.random(1, count_table(prompts))]
	local verb 				= verbs[math.random(1, count_table(verbs))]
	local prep 				= preps[math.random(1, count_table(preps))]
	local location 			= locations[math.random(1, count_table(locations))]
	local adj 				= adjs[math.random(1, count_table(adjs))]
	local adv 				= advs[math.random(1, count_table(advs))]
	local gerund 			= gerunds[math.random(1, count_table(gerunds))]
	local conj 				= conjs[math.random(1, count_table(conjs))]	
	local questionCap 		= questionCaps[math.random(1, count_table(questionCaps))]
	local question 			= questions[math.random(1, count_table(questions))]
	local prompt2 			= prompts[math.random(1, count_table(prompts))]
	local verb2 			= verbs[math.random(1, count_table(verbs))]
	local prep2 			= preps[math.random(1, count_table(preps))]
	local location2 		= locations[math.random(1, count_table(locations))]
	local adj2 				= adjs[math.random(1, count_table(adjs))]
	local adv2 				= advs[math.random(1, count_table(advs))]
	local gerund2 			= gerunds[math.random(1, count_table(gerunds))]
	local conj2 			= conjs[math.random(1, count_table(conjs))]	
	local questionCap2	 	= questionCaps[math.random(1, count_table(questionCaps))]
	local altQuestionCap 	= altQuestionCaps[math.random(1, count_table(altQuestionCaps))]
	local pronoun 			= pronouns[math.random(1, count_table(pronouns))]


	----------------------
	--Questions-----------
	----------------------

	if isQuestion then 
		sentence = question 
		--if pattern == "short" then 

			replace_excludes(verb, verb2, gerund, noun, noun2, questionCap, altQuestionCap, location, question, determiner, shortexcludes)

			for b=1, count_table(shortexcludes) do
				if verb == shortexcludes[b] then verb = verb2 end
				if verb2 == shortexcludes[b] then verb = verbs[math.random(1,count_table(verbs))] end

				if gerund == shortexcludes[b] then gerund = gerund2 end
				if gerund2 == shortexcludes[b] then gerund = gerunds[math.random(1,count_table(gerunds))] end
			end

			if gerund == "placing" or gerund == "putting" then
				sentence = sentence .. " " .. gerund .. "\n" .. pronoun .. " " .. prep .. "\n" .. location
				if question == "is" or question == "how is" then 
					sentence = sentence .. "\n" .. altQuestionCap
				elseif question == "have you tried" then
					sentence = sentence .. "?"
				else
					sentence = sentence .. "\n" .. questionCap
				end
			elseif  gerund == "questioning" or gerund == "satisfying" then
				sentence = sentence .. "\n" .. gerund .. " ".. pronoun .. "\n" .. altQuestionCap
			elseif question == "is" or question == "how is"  then 
				sentence = sentence .. "\n" .. gerund .. "\n" .. altQuestionCap
			elseif question == "have you tried" then sentence = sentence .. "\n" .. gerund .. " " .. pronouns[math.random(1,3)] .. "?"
			elseif question == "should" then sentence = sentence .. " you " .. "\n" .. verb .. " " .. pronouns[math.random(1,3)] .. "?"
			else 
				sentence = sentence .. "\n" .. gerund .. "\n".. determiner .. "\n" ..  noun .. "\n" .. questionCap
		
			end
		--end
	
	----------------------
	--Commands------------
	----------------------

	elseif isCommand then 

		replace_excludes(verb, verb2, gerund, noun, noun2, questionCap, altQuestionCap, location, question, determiner, commandexcludes)

		if pattern == "short" then
			replace_excludes(verb, verb2, gerund, noun, noun2, questionCap, altQuestionCap, location, question, determiner, {"place"})
			if plural then sentence = verb .. "\n" .. noun
			else sentence = verb .. " " .. determiner  .. "\n" .. noun
			end
		else
		
			local cap = math.random(1,100)
			if cap <= 50 then 
				cap = prep .. "\n" .. location 
			else
				cap = adv
			end

			if prep == "before" or prep == "beneath"  or prep == "above" then 
				replace_excludes(verb, verb2, gerund, noun, noun2, questionCap, altQuestionCap, location, question, determiner, beneathbelow_excludes)
				prep = adj .. "\n" .. prep 

			end

			if verb == "replace" then 
				prep = "with" 
				sentence = verb .. " " .. determiner .. "\n".. noun .. " " .. prep .. "\n" .. noun2
			elseif verb == "simplify" then 
				if not plural then sentence = verb .. " " .. prep .. "\n" .. noun
				else sentence = verb .. " " .. prep .. "\n" .. determiner .. " " .. noun
				end
			elseif verb == "connect" then 
				sentence = verb .. " " .. noun .. "\n" .. "to " ..  determiner .. "\n" .. pluralNouns[math.random(1,count_table(pluralNouns))]
			elseif verb == "place" then
				sentence = verb .. "\n" .. determiner .. " ".. pluralNouns[math.random(1, count_table(pluralNouns))] .. "\n"  .. cap
			else
				sentence = verb .. " " .. determiner .. "\n".. noun .. " " .. cap
			end
		end


	----------------------
	--SUGGESTION PLACEHOLDER------------
	----------------------

	elseif isSuggestion then 

		if pattern == "short" then
			if plural then sentence = verb .. "\n" .. noun
			else sentence = verb .. " " .. determiner  .. "\n" .. noun
			end
		else
		
			if verb == "replace" then prep = "with" end
			if verb == "simplify" then 
				if not plural then sentence = verb .. " " .. prep .. "\n" .. noun
				else sentence = verb .. " " .. prep .. "\n" .. noun
				end
			elseif verb == "connect" then 
				sentence = verb .. " " .. noun .. "\n" .. "to " ..  determiner .. "\n" .. nouns[math.random(1,count_table(nouns))]
			elseif verb == "place" then
				sentence = verb .. " " .. noun .. "\n" .. prep .. "\n" .. location
			else
				sentence = verb .. " " .. determiner .. "\n".. noun .. " " .. prep .."\n" .. location
			end
		end

	end
	
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
	if gfx.mouse_cap == 1 or char ==  32 then
		message = new_message()
		f = .19
	end

end

main()