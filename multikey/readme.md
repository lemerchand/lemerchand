## Introduction
Okay...So maybe you are interested in consolidating your action bindings to a smaller part of your keyboard, or perhaps you want to try a more mnemonic approach to your keys to make it easier to remember them. Cool. That's what this script is all about. 

## Features
- Assign an action or multiple actions to a string of keys
- Combine actions from both the Midi Editor and Trackview
- A (possibly) quicker way of making custom actions
- Assign bindings in a mnemonic way

## Example Bindings
Maybe you want to have a key for going places. Let's make that key `G` You could set it up like:
- GG - Go to the begining of the project (or if in the midi editor to the begining)
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
In order for Multikey to know what key invoked it, it is necessary to have a separate script for each first key. These are in the `Keyscripts` folder and contain mini-scripts that you bind to the first key stroke. They then call the main script and look through the following key presses. For example, if you wanted to bind quantization actions to `Q` you would go into the Action List and load/bind 'q-Multikey-Script.lua` to `Q.`

Then run the script (ie, press `Q`). Multikey will generate a file under `Bindings` called `q-Multikey-Bindings.conf.` In this file we define our keybindings. Let's look up 'Quantize Item Positionss to Grid' in the Actions List. Then in the conf file we might put:

```
--Q Quantize items to grid
main: 40316
```

The `--` is a comment and is optional, although it's probably a good idea to keep track of your bindings. Besides, in the future I may use them to display a bindings list in GUI form. `main:` 

What if we want to add the same keybinding to the MIDI Editor but for quantizing notes to the grid? In this case we just preface the MIDI Editor action with and `m` to let Multikey know it's meant to run a MIDI Editor action:
```
-- Quantize events to grid
midi: qq m40728
```
