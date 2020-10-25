
## MIDI Selection Tool v.9b

![Selecting Notes](https://t2361428.p.clickup-attachments.com/t2361428/f4ada0df-c594-47ac-8ddc-d258eac1de16/selecting_notes.gif?view=open)

**Description:**

A tool for quickly selecting midi notes in REAPER. Filters for events such as:
		
		- Note Range
		- Pitch
		- Min/Max Velocity 
		- Beat position in 16th notes (sorry--no odd time signatures)

**What's New!?**

		- Shift + L-click "Select" to invert the filter
		- Click "Capture" to set parameters from selected notes (global)
		- Shift + L-Click to set individual parameters from selected notes
		- Right-click "Select" to restrict selected notes to  time selection
		- Better handling of velocity slider
		- Ctrl+LC on a toggle button to exclusive-select it
		- Added version number to titlebar

**Cool Features:**

		- Right-click toggle buttons to reset that section to default
		- Right-click 'Clear' button for global reset 
		- 'A,' 'B,' and 'C' buttons load beat presets
			    - Modifications to a preset persist until global reset or script closes
		- Help-text on mouse hover

**Known Issues**

		- Entering an invalid note range isn't error-handled
		- Inclusive select only works with velocity
		- My code is messy

**Some things I want to add:**

		- The ability to store user-defined beat presets in a file 
		- Inclusive selection
		- Pitch presets based on scales
		- Info on selected notes displayed (eg., how many notes were selected)

**Installation:**

If you don't use github then click the "code" button and select "Download Zip." Chose your REAPER resources path (usually something like c:/users/yourname/appdata/roaming/reaper) and unzip it in the 'Scripts' folder. 

Then you'll need to bind it to a hotkey. Run the actions menu and select MIIDI Editor. Click 'Load Reascript' and navigate to the 'Lemerchand' where you unzipped the files. Select "midi_selector.lua" and choose a key. 

Finally, when in the midi editor, press said key and the GUI will pop up allowing you to select notes quickly. Be sure to read the help text in the "Info" frame. 

**Contact:**

Email me (arsnocturnaaudio@gmail.com) or hit me up on Discord (Robert ±#0379) with any questions, feedback, bugs, hi-fives. 	

Special thanks to the Cockos, the REAPER community, and especially Stevie and Birdbird (and everyone else) from the Reascript Discord for their support, suggestions, and lulz. 