
## MIDI Selection Tool v1.0b

![Demo](https://t2361428.p.clickup-attachments.com/t2361428/3f5587aa-833f-4cab-8b80-c9cc140aa938/dem.gif?view=open)

**Description:**

A tool for quickly selecting midi notes in REAPER. Filters for events such as:
		
		- Note Range
		- Pitch (including scales!)
		- Min/Max Velocity 
		- Note length (no dotted yet)
		- Beat position in 16th notes (sorry--no odd time signatures)

**Cool Features:**
		- Save your favorite settings into presets!
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
			- If they do, simply reload the default config (Right-click "Save" under "Settings")

**Some things I want to add:**

		- Inclusive selection
		- Info on selected notes displayed (eg., how many notes were selected)

**Installation:**

Dependencies: 
	
	- JS Reascript API (download from reapack)
	- My gui.lua/cf.lua files 
	- Directory structure must be your REAPER resource path then:
		- /Scripts/lemerchand/Midi Selector Tool
		- gui.lua/cf.lua in the lemerchand directory


1. Goto: https://github.com/lemerchand/lemerchand

2. Either clone the repo or if you don't use github then click the "code" button and select "Download Zip." Chose your REAPER resources path (usually something like c:/users/yourname/appdata/roaming/reaper) and unzip it in the 'Scripts' folder. 

3. Rename the folder from "lemerchand - master" to "lemerchand"

4. Bind it to a hotkey. Run the actions menu and select MIIDI Editor. Click 'Load Reascript' and navigate to the 'Lemerchand/MIDI Selector Tool' where you unzipped the files. Select "MIDI Selector Tool.lua" and choose a hotkey. 

Finally, when in the midi editor, press said key and the GUI will pop up allowing you to select notes quickly. Be sure to read the help text in the "Info" frame. 


**Usage:**

Select & Clear 

![Select & Clear](https://t2361428.p.clickup-attachments.com/t2361428/32a91a63-ca6b-4e5a-a4f1-2eb1dce5a085/select-clear.gif?view=open)

Capture
![Capture](https://t2361428.p.clickup-attachments.com/t2361428/f0e4d949-29de-4b9e-92d5-e6cee17cccd6/capture.gif?view=open)

Beats
![Beats](https://t2361428.p.clickup-attachments.com/t2361428/a3529dbe-2b58-4b2b-9b81-5672b5497068/beats.gif?view=open)

Note Lengths
![Note Lengths](https://t2361428.p.clickup-attachments.com/t2361428/4417adfe-444a-493a-8039-545e02280789/timeinlength.gif?view=open)

Scales
![Scales](https://t2361428.p.clickup-attachments.com/t2361428/a77b90d7-9e67-46ae-8ff1-728899d465cb/scales.gif?view=open)


**Backup your presets and config files before updating!**

**Contact:**

Email me (arsnocturnaaudio@gmail.com) or hit me up on Discord (Robert ±#0379) with any questions, feedback, bugs, hi-fives. 	

Special thanks to the Cockos, the REAPER community, and especially Stevie and Birdbird (and everyone else) from the Reascript Discord for their support, suggestions, and lulz. 

**Donations:** 

If you feel like these scripts benefit you at all and you'd like to support me in creating more then consider a small donation to me at https://www.paypal.com/paypalme/arsnocturna.