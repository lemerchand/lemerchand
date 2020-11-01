
## MIDI Selection Tool v.998b

![Demo](https://t2361428.p.clickup-attachments.com/t2361428/9812d5e3-079e-4ec7-b53e-31a32272d4d1/dem.gif?view=open)

**Description:**

A tool for quickly selecting midi notes in REAPER. Filters for events such as:
		
		- Note Range
		- Pitch
		- Min/Max Velocity 
		- Note length (no triplets or dotted yet)
		- Beat position in 16th notes (sorry--no odd time signatures)

**Cool Features:**

		- Right-click "Select" to restrict to the time selection
		- Shift-click "Select" to invert the filter
		- Right-click 'Clear' for a global reset
		- Drag over beats/pitches to 'draw' patterns quickly
		- Right-click a control to reset it
		- Click 'Capture' to set the parameters dfrom the currently selected notes!
		- Shift-click a control to set it's parameters to currently selected notes.
		- Shift-click a beat for a preset. Shift-right click to store in that slot.
		- Ctrl-click and drag velocity slider to move note range
		- Built-in documentation (hoverr over a control for info!)
		- Adjustable threshold for length/grid detection in PPQ

**Known Issues**

		- Entering an invalid note range isn't error-handled
		- Some issues might occure with saving.
			- If they do, simply reload the default config

**Some things I want to add:**

		- Inclusive selection
		- Pitch presets based on scales
		- Info on selected notes displayed (eg., how many notes were selected)

**Installation:**

Dependencies: 
	
	- JS Reascript API (download from reapack)
	- My gui.lua/cf.lua files 
	- Directory structure must be your resource path then:
		- /Scripts/lemerchnd/Midi Selector Tool
		- gui.lua/cf.lua in the lemerchand directory


If you don't use github then click the "code" button and select "Download Zip." Chose your REAPER resources path (usually something like c:/users/yourname/appdata/roaming/reaper) and unzip it in the 'Scripts' folder. 

Then you'll need to bind it to a hotkey. Run the actions menu and select MIIDI Editor. Click 'Load Reascript' and navigate to the 'Lemerchand/MIDI Selector Tool' where you unzipped the files. Select "MIDI Selector Tool.lua" and choose a hotkey. 

Finally, when in the midi editor, press said key and the GUI will pop up allowing you to select notes quickly. Be sure to read the help text in the "Info" frame. 


**Usage:**

Select & Clear 

![Select & Clear](https://t2361428.p.clickup-attachments.com/t2361428/6efef399-0277-48e2-a40d-54ae0f79aafe/select-clear.gif?view=open)

Capture
![Capture](https://t2361428.p.clickup-attachments.com/t2361428/2d6eac77-210a-4cb0-b2a4-76be8315dbd2/capture.gif?view=open)

Beats
![Beats](https://t2361428.p.clickup-attachments.com/t2361428/e640485a-de4a-4d98-8457-bc13d7ea3bfb/beats.gif?view=open)

**Contact:**

Email me (arsnocturnaaudio@gmail.com) or hit me up on Discord (Robert ±#0379) with any questions, feedback, bugs, hi-fives. 	

Special thanks to the Cockos, the REAPER community, and especially Stevie and Birdbird (and everyone else) from the Reascript Discord for their support, suggestions, and lulz. 