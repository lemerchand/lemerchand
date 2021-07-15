## Introduction
Okay...So maybe you are interested in consolidating your action bindings to a smaller part of your keyboard, or perhaps you want to try a more mnemonic approach to your keys to make it easier to remember them. Cool. That's what this script is all about. 

## Features
- Assign an action or multiple actions to a string of keys
- Combine actions from both the Midi Editor and Trackview
- A (possibly) quicker way of making custom actions
- Assign bindings in a mnemonic way

## Example Bindings
Maybe you want to have a key for going places. Let's make that key `G` You could set it up like:
- GG - Go to the beginning of the project (or if in the midi editor to the beginning)
- GE - Go to the end of the project (or if in the midi editor to the end)
- GNM - Goto the next marker
- GBM - Go back a marker

I have various split actions bound to `x`
- XX - Split at the mouse cursor ignoring snap
- XS - Split at the mouse cursor obeying snap
- XG - Split note or item on the grid
- XT - Split at time selection

What about binding multiple actions to one key sequence? We can do that too!
- RC - Enable click and begin recording
- RCC - Enable click and countin and begin recording
- CE - Copy item and move edit cursor to it's right edge (maybe you want to immediately paste it, I don't know!)


## Caveats
It's all still in beta, and even when it isn't, one prerequisite will be being comfortable with editing configuration files.

## Setup
In order for Multikey to know what key invoked it, it is necessary to have a separate script for each first key. These are in the `Keyscripts` folder and contain mini-scripts that you bind to the first key stroke. They then call the main script and look through the following key presses.

I suggest opening the Actions List, clicking 'New Script' then 'Load Reascript', navigating to the 'Keyscript' folder, pressing Ctrl-A to select and load all of them at once. Then you can type 'multikey' into the Action List to see all of the bindings at once. It's possible to set them all once by making each one global, but (as tedious as it is) you should load the scripts separately for both Main and MIDI Editor. 

![Image](https://ibb.co/ZS7dWZn)


Now, for example, if you wanted to bind quantization actions to `Q` you would go into the Action List and load/bind 'q-Multikey-Script.lua' to `Q.`

If you don't already have a bindings file for `Q` you can simply call `Q` and Multikey will generate a file under `Bindings` called `q-Multikey-Bindings.conf.` In this file we define our keybindings. Note that you do not have to have a separate bindings file for Main and MIDI Editor. Let's look up 'Quantize Item Positionss to Grid' in the Actions List. Then in the conf file we might put:

```
--Q Quantize items to grid
main: q 40316
```

The `--` is a comment and is optional, although it's probably a good idea to keep track of your bindings. Besides, in the future I may use them to display a bindings list in GUI form. 

What if we want to add the same keybinding to the MIDI Editor but for quantizing notes to the grid? In this case we just preface the MIDI Editor action with and `m` to let Multikey know it's meant to run a MIDI Editor action:
```
-- Quantize events to grid
midi: q m40728
```

Now, if you are in trackview or the MIDI Editor, pressing `Q` will quantize either an item in trackview, or a not in the MIDI Edior. 

Let's take it a step further and add a logical binding to open the Quantization Dialog in the MIDI Editor. We'll assign it to the sequence `QD` like this:

```
-- Open Quantization Dialog
midi: qd m40009
```

Save your 'q-Multikey-Bindings.conf' script and select some off-time notes in the MIDI Editor. Press `qd`. Now the MIDI Quantizatio Dialog will show up. For now, let's leave it alone--that is, click 'Cancel.' Now press our original `Q` binding, Notice that now there is a slight time delay before the action takes place?

This is because Multikey uses a variable called 'timeout' that will tell the script to stop looking for new key presses after a specified time, or if the longest sequence of keys has already been pressed. This variable can be edited by editing the value in 'settings.conf' 

Let's now make an action that works both in trackview and the MIDI Editor. Assign the 'm-Multikey-Script.lua' file to `M`. Run it to generate the bindings file, then open that in your text editor, and enter the following:

```
-- Insert or Edit marker at cursor
all: mm 40171
```
There is no actino in the Action List for inserting a marker in the MIDI Editor. But with Mulitkey you can assign a key to the context `all` to run whatever action you want. Keep in mind, if it's a MIDI Editor command it must be prefaced with 'm.' In this case, we can assign a marker at the cursor with `mm` in trackview OR in the MIDI Editor. 

Finally, if you want to emulate Custom Actions, you can simply chain them together. 

```
-- Turn on Metronome and enable Count in before record
main: rcc 41745 _SWS_AWCOUNTRECON
```
