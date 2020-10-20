
## MIDI Selection Tool v.85b


**NEW!**
		- Click "Sample" to set parameters from selected notes (global)
		- Shift + L-Click to set individual parameters from selected notes
		- Right-click "Select" to restrict selected notes to  time selection
		- Better handling of velocity slider
		- Ctrl+LC on a toggle button to exclusive-select it
		- Script can act on any focused midi editor window


**Description:**
Selects only midi notes in a take or time selection based user parameters including:
		
		- Note Range
		- Pitch
		- Min/Max Velocity 
		- Beat position in 16th notes (sorry--no odd time signatures)


**Cool Features:**

		- Right-click toggle buttons to reset that section to default
		- Right-click 'Clear' button for global reset 
		- 'A,' 'B,' and 'C' buttons load beat presets
			    - Modifications to a preset persist until global reset or script closes
		- Help-text on mouse hover

**Known Issues**

		- Entering an invalid note range isn't error-handled
		- Inclusive select only works with velocity
		- Delete button is dumb and should be something else
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

Email me with any questions: arsnocturnaaudio@gmail.com
Discord: Robert ±#0379