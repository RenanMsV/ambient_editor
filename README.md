# FlightGear Ambient Editor Addon
Change your simulator color schemes. Let it better for you !

### Requirements

* FlightGear 2017.3.1 version (up to v3) or 2020.1+
* ALS Disabled
* Rembrandt Disabled

### Releases
* 0.5.0 : 2020.1.0 compatibility.
* 0.4.0 : 2018.1 compatibility.
* 2017.3.1 : 2017.3.1 --addon compatibility.
* v2 : Second release. Presets available.
* v1 : First release. No presets available.

### Install Procedures

Unzip ambient_editor folder to any place you want. e.g C:\Users\USERNAME\Documents\FlightGear\Addons\ambient_editor

Then add this command line to your FlightGear Shortcut :

--addon="C:\Users\USERNAME\Documents\FlightGear\Addons\ambient_editor"

Note that this command line must have the correct path to the ambient_editor folder. Do not know how to set command lines? Check here: http://wiki.flightgear.org/Command_line

### How Presets Works

Save Button : Use this button to save your current scheme. That will be saved to appdata and must be manually moved to presets folder that is inside the addon installation folder. Thats because FG can not write files outside of appdata.

Load Button : Show a list of the saved presets wich can be selected at runtime.

### Known Issues:

Does not follow the day and night cycle. Therefore, the schema will remain the same until changed or deactivated. If disabled, it will return to normal FlightGear scheme.

![Profile](https://i.imgur.com/lYwX6e3.png)
