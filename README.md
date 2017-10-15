# FlightGear Ambient Editor Addon
Change your simulator color schemes. Let it better for you !

### Requirements

* FlightGear 2017.3.1 version (up to v3)
* ALS Disabled
* Rembrandt Disabled

### Releases
* v1 : First release. No presets available.
* v2 : Second release. Presets available.
* v3 : WIP. 2017.3.1 --addon compatibility.

### Install Procedures

Unzip ambient_editor folder to any place you want. e.g C:\Users\USERNAME\Documents\FlightGear\Addons\ambient_editor

Then add this command line to your FlightGear Shortcut :

--addon="C:\Users\USERNAME\Documents\FlightGear\Addons\ambient_editor"

Note that this command line must have the correct path to the ambient_editor folder. Do not know how to set command lines? Check here: http://wiki.flightgear.org/Command_line

### How Presets Works

Save Button : Use this button to save your current scheme. That must be saved at $FG_HOME/Export and be manually moved to ambient_editor/presets folder. Thats because FG can not write files outside $FG_HOME folder.

Load Button : Show all presets in ambient_editor/presets folder wich can be selected at runtime.

### Known Issues:

Does not follow the day and night cycle. Therefore, the schema will remain the same until changed or deactivated. If disabled, it will return to normal FlightGear scheme.

![Profile](https://i.imgur.com/lYwX6e3.png)
