
## MIDI Selection Tool v.75b*


**NEW!**
		- Ctrl+LC on a toggle button to exclusive-select it
		- Script acts on currently focused midi window

Select any note within a take or time selection (latter feature coming soon) based on a number of parameters including:
		
		- Note Range
		- Pitch
		- Velocity 
		- Beat position in 16th notes


**Cool Features:**

		- Right-click anything to reset just THAT section
		- Right-click 'Clear' button for global reset 
		- 'A,' 'B,' and 'C' buttons load beat presets
			    - Modifications to a preset persist until global reset or script closes
		- Help-text on mouse hover

**Known Issues**

		- Entering an invalid note range isn't error-handled
		- Inclusive select only works with velocity
		- Delete and Time selection are not yet implemented
		- Works based off active take and not the current midi window
		- My code is messy

**Some things I want to add:**

		- The ability to store user-defined beat presets in a file 
		- The ability to select notes only in time-selection, or already selected
		- Pitch presets based on scales
		- Info on selected notes displayed (eg., how many notes were selected)

**Installation:**

Place ui.lua, cf.lua, and midi_selector.lua into a folder called "lemerchand" inside your "Scripts" directory in the REAPER resources path. Go into your MIDI editor and run "Action List." Search for "Midi Selector" and bind it to a key of your choice ("T" if you have it available.)

Make sure the midi item you want to use the script on is selected and then run the script in the midi editor window.