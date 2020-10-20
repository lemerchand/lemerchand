
## MIDI Selection Tool v.85b


**NEW!**
		- Set the selection parameters by selected notes
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

Place ui.lua, cf.lua, and midi_selector.lua into a folder called "lemerchand" inside your "Scripts" directory in the REAPER resources path. Go into your MIDI editor and run "Action List." Search for "Midi Selector" and bind it to a key of your choice ("T" if you have it available.)

Make sure the midi item you want to use the script on is selected and then run the script in the midi editor window.