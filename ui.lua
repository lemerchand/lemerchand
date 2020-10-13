-------------------------------------------------------------------------------
--					User Interface Library
-------------------------------------------------------------------------------
-- Modified: 2020.10.13
--
--TODO: 
-- 		+ Fix h_slider() when backwards = true
-- 		+ Statusbar toolsips
-- 		+ Useful info display
-------------------------------------------------------------------------------

mouse_down = 0

function fill_background()
	local r, g, b, a = .19,.19,.19, 1
	local w, h = gfx.w, gfx.h

	gfx.set(r,g,b,a)
	gfx.rect(0,0,w,h,true)

end

function label(x,y,text, r, g, b)
	gfx.x, gfx.y = x, y
	gfx.a = .7
	gfx.setfont(2,"Lucinda Console",20,'b')
	if r and g and b then 
		gfx.r, gfx.g, gfx.b = r, g, b
	else
		gfx.r, gfx.g, gfx.b = .8,.8,.8
	end
	gfx.drawstr(text)
end

function text(x,y,text, r, g, b)
	gfx.x, gfx.y = x, y
	gfx.a = 1
	gfx.setfont(3,"Lucinda Console",16,'')
	if r and g and b then 
		gfx.r, gfx.g, gfx.b = r, g, b
	else
		gfx.r, gfx.g, gfx.b = .8,.8,.8
	end
	gfx.drawstr(text)
end

function option_text(x,y,text, r, g, b)
	gfx.setfont(3,"Lucinda Console",16,'')
	gfx.x, gfx.y = x, y
	gfx.a = 1
	gfx.set(.7,.7,.6, 1)
	local w, h = gfx.measurestr(text)

	gfx.rect(x, y, w+8, h+5, false)
	gfx.set(.25,.25,.25)
	gfx.rect(x+1,y+1,w+6,h+3, true)

	if r and g and b then 
		gfx.r, gfx.g, gfx.b = r, g, b
	else
		gfx.r, gfx.g, gfx.b = .8,.8,.8
	end

	gfx.x, gfx.y = x+4, y+2
	gfx.drawstr(text)

	return text
end


function small_toggle(x,y,text, state)
	-- Creates a toggle button at x and y with text.
	-- 
	-- Set font size then measure the width of the text. Makes the button bigger than the text
	gfx.setfont(4, "Lucinda Console",16, '')
	w,h = 19,18
	
	-- Create button graphic

	if state == 1 then
		gfx.set(.5,.26,.36,1)
		gfx.rect(x,y, w+8,h+5, true)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x+1,y+1, w+6, h+3, false)

		-- Set text
		
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+4,y+4
		gfx.drawstr(text)
	else
		gfx.set(.25,.25,.25,1)
		gfx.rect(x,y, w+8, h+5)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x+1,y+1, w+6, h+3, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+4,y+4
		gfx.drawstr(text)
	end
	-- Detect left mouse click on hover
	if gfx.mouse_x > x and gfx.mouse_x < x + w+8 and gfx.mouse_y > y and gfx.mouse_y < y+h+6 and  gfx.mouse_cap == 1  then
		-- Create button graphic
		gfx.set(.22,.22,.24,1)
		gfx.rect(x,y, w+8, h+5)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x+1,y+1, w+6, h+3, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+4,y+4
		gfx.drawstr(text)
		mouse_down = 1
		return 0
	-- Detect just a hover
	elseif gfx.mouse_x > x and gfx.mouse_x < x + w+8 and gfx.mouse_y > y and gfx.mouse_y < y+h+6 and mouse_down == 1 then
		-- Create button graphic
		gfx.set(.3,.3,.3,.6)
		gfx.rect(x,y, w+8, h+5)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x+1,y+1, w+6, h+5, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+4,y+4
		gfx.drawstr(text)
		mouse_down = 0
		return 1
	elseif gfx.mouse_x > x and gfx.mouse_x < x + w+8 and gfx.mouse_y > y and gfx.mouse_y < y+h+6  then
		-- Create button graphic
		gfx.set(.3,.3,.3,.6)
		gfx.rect(x,y, w+8, h+5)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x+1,y+1, w+6, h+3, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+4,y+4
		gfx.drawstr(text)
		return 0
	-- Anything else
	else
		return 0
	end

	return text
end


function cons(text, p)
	if p == true then reaper.ClearConsole() end
	reaper.ShowConsoleMsg(text)
end

function button(x,y,text, offset)
	-- Creates a button at x and y with text.
	-- Returns 1 if left mouse clicks within the button and 0 if not
	-- Convert text length into pixels
	gfx.setfont(1, "Lucinda Console",18, 'b')
	local button_width, button_height = gfx.measurestr(text)
	if offset then button_width = button_width + offset end
	-- Create button graphic
	gfx.set(.25,.25,.25,1)
	gfx.rect(x,y, button_width+29, 30)
	gfx.r, gfx.g, gfx.b = .5, .5, .5
	gfx.rect(x-1,y-1, button_width+30, 31, false)

	-- Set text

	gfx.r, gfx.g, gfx.b = .7, .7, .7
	gfx.x, gfx.y = x+13,y+6
	gfx.drawstr(text, 1)


	-- Detect left mouse click on hover
	if gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30 and  gfx.mouse_cap == 1 then
		-- Create button graphic
		gfx.set(.22,.22,.24,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		mouse_down = 1
		return 0
	-- Detect just a hover
	elseif gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30  and mouse_down == 1 then
		-- Create button graphic
		gfx.set(.3,.3,.3,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		mouse_down = 0
		return 1


	-- Detect rick mouse click on hover
	elseif gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30 and  gfx.mouse_cap == 2 then
		-- Create button graphic
		gfx.set(.22,.22,.24,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		mouse_down = 2
		return 0

	-- Detect just a hover
	elseif gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30  and mouse_down == 2 then
		-- Create button graphic
		gfx.set(.3,.3,.3,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		mouse_down = 0
		return 2


	elseif gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30  then
		-- Create button graphic
		gfx.set(.3,.3,.3,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		return 0

	-- Anything else
	else
		return 0
	end
end


function toggle(x,y,text, state)
	-- Creates a toggle button at x and y with text.
	-- 
	-- Set font size then measure the width of the text. Makes the button bigger than the text
	gfx.setfont(1, "Lucinda Console",18, 'b')
	local button_width, button_height = gfx.measurestr(text)
	
	-- Create button graphic

	if state == 1 then
		gfx.set(.5,.26,.36,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
	else
		gfx.set(.25,.25,.25,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
	end
	-- Detect left mouse click on hover
	if gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30 and  gfx.mouse_cap == 1  then
		-- Create button graphic
		gfx.set(.22,.22,.24,1)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		mouse_down = 1
		return 0
	-- Detect just a hover
	elseif gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30 and mouse_down == 1 then
		-- Create button graphic
		gfx.set(.3,.3,.3,.6)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		mouse_down = 0
		return 1
	elseif gfx.mouse_x > x and gfx.mouse_x < x + button_width+29 and gfx.mouse_y > y and gfx.mouse_y < y+30  then
		-- Create button graphic
		gfx.set(.3,.3,.3,.6)
		gfx.rect(x,y, button_width+29, 30)
		gfx.r, gfx.g, gfx.b = .5, .5, .5
		gfx.rect(x-1,y-1, button_width+30, 31, false)

		-- Set text
		gfx.r, gfx.g, gfx.b = .7, .7, .7
		gfx.x, gfx.y = x+13,y+6
		gfx.drawstr(text, 1)
		return 0
	-- Anything else
	else
		return 0
	end
end


function frame(x,y,w,h)
	gfx.a = 1

	gfx.r, gfx.g, gfx.b = .4,.4,.4
	gfx.roundrect(x, y, w+1, h+1, 4,true)
	-- Make thicker
	gfx.r, gfx.g, gfx.b = .4,.4,.4
	gfx.roundrect(x+1, y+1, w-1, h-1, 4, true)



------------------------------------------
---OG Frame
-----------------------------------------
	-- gfx.a = 1
	-- -- Background
	-- gfx.r, gfx.g, gfx.b = .22,.22,.22
	-- gfx.rect(x+2, y+2, w-5, h-5, 1)

	-- -- -- Main frame
	-- -- gfx.r, gfx.g, gfx.b = .65,.65,.65
	-- -- gfx.rect(x-1, y-1, w, h, 0)

	-- -- -- Shadow 1
	-- -- gfx.r, gfx.g, gfx.b = .54,.54,.54
	-- -- gfx.rect(x, y, w-2, h-2, 0)

	-- -- -- Shadow 2
	-- -- gfx.r, gfx.g, gfx.b = .3,.3,.3
	-- -- gfx.rect(x+1, y+1, w-4, h-4, 0)

end

function h_slider(x,y, text, value, min_value, max_value, backwards)

	--Catch lower than min and higher than max values 
	if value < min_value then value = min_value elseif value > max_value then value = max_value end

	--Calculate the percentage of value and max_value
	percent = value / max_value * 100
	fill = percent*1.46

	-- Create UI element
	gfx.set(.31,.21,.7,1)
	gfx.x, gfxy = x,y
	gfx.rect(x,y,150,28,false)
	gfx.rect(x+1,y+1,148,26,false)

	--Fill in value based on percent
	gfx.set(.23,.19,.57,1)
	
	if backwards == true then 
		gfx.rect(fill-4,y+4, fill,20,true)

	else
		gfx.rect(x+4,y+4, fill-4,20,true)
	end

	--Draw text
	gfx.x, gfx.y = x+10, y+7
	gfx.set(.8,.8,.8,1)
	gfx.setfont(3, "Lucida Consolde", 16)
	gfx.drawstr(text .. ": " .. value .. " / " .. max_value)

	-- If the mouse is inside the slider and the left button is clicked
	if gfx.mouse_x >= x and gfx.mouse_x < x + 148 and gfx.mouse_y > y and gfx.mouse_y < y+28 and  gfx.mouse_cap == 1 then
		
		
		if math.ceil(value) > max_value then
			new_value = max_value
		elseif math.floor(value) < min_value then
			new_value = min_value
		else 
			new_value = math.ceil(((gfx.mouse_x-x)/147)*max_value)
			
		end
		return math.ceil(new_value)
	else
		return value
	end



end