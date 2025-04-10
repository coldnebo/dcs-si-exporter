# dcs-si-exporter

Digital Combat Simulator (DCS) scripts to integrate with [SayIntentions](https://www.sayintentions.ai/) via their [simAPI](https://www.sayintentions.ai/simapi).

The goal is to have working ATC provided by SayIntentions in DCS.

AMAZING!!!

(Thanks to Brian and all the SayIntentions crew for spiking this simAPI so quickly!)


## Current Status

Work in Progress


### MVP Requirements

Features and Current Status:

* implement [SayIntensions simAPI](https://sayintentionsai.freshdesk.com/support/solutions/articles/154000221017-simapi-developer-howto-integrating-sayintentions-ai-with-any-flight-simulator)
  * simAPI_input.json - input to the SayIntentions client from this exporter
    * [DONE] setup default structure, required and optional parameters and types
  * simAPI_output.jsonl - output from the SayIntensions client to this exporter (append on update)
  	* [INPROGRESS] clear after read



 ### Input Data

* All required fields implemented or hardcoded for now.
* only COM1 supported in the F-16C currently
* only VHF radio mapped to COM1
* COM2 disabled
* transponder hardcoded to 1200, and ALT (mode-c) on.

* [TODO] Optional fields?
  * `ZULU TIME` and `LOCAL TIME` maybe from mission data?

* `COM ACTIVE FREQUENCY:1` 
  * support 8.333KHz channel spacing
  * read from F-16C (different aircraft will require different device access)
  * [TODO] read from other aircraft
  * [DONE] support being set by SI client -- this requires the incremental read feature.

* `MAGVAR`
	* hardcoded for now
	* [TODO] lookup current map in DCS and apply magvar average?? or find other source?

* `PLANE ALT ABOVE GROUND MINUS CG`
  * F-16C seems to be 5 feet above the ground when on the ground so hard-coded offset -5.
  * [TODO] per plane map of offsets? some other way to determine `SIM_ON_GROUND` ?

* `SEA LEVEL PRESSURE`
	* hardcoded to 29.92 for now.
	* [TODO] read from mission data? 

* `TRANSPONDER CODE:1`
  * hardcoded to 1200 for now
  * [TODO] read from F-16C
  * [TODO] lookup for other aircraft

* `TRANSPONDER IDENT` - NA
  * [TODO] implement? not sure where this equivalent function is in the F-16C?

* `TRANSPONDER STATE:1` 
	* hardcoded to 4 (ALT ON, mode C)
	* [TODO] implement other modes? this is a nice to have, but probably OFF and ALT make sense.
	         others may not have equivalents in F-16C? 
	         0 = Off, 1 = Standby, 2 = Test, 3 = On, 4 = Alt, 5 = Ground

example

```json
{
    "sim": {
        "adapter_version": "0.1",
        "exe": "DCS.exe",
        "name": "DCS World",
        "simapi_version": "1.0",
        "variables": {
            "AIRSPEED INDICATED": 4,
            "AIRSPEED TRUE": 0,
            "AMBIENT WIND DIRECTION": 0,
            "AMBIENT WIND VELOCITY": 0,
            "CIRCUIT COM ON:1": 1,
            "CIRCUIT COM ON:2": 1,
            "COM ACTIVE FREQUENCY:1": 121.5,
            "COM ACTIVE FREQUENCY:2": 100,
            "COM RECEIVE:1": 1,
            "COM RECEIVE:2": 0,
            "COM TRANSMIT:1": 1,
            "COM TRANSMIT:2": 0,
            "ELECTRICAL MASTER BATTERY:0": 1,
            "ENGINE TYPE": 1,
            "INDICATED ALTITUDE": 1847,
            "LOCAL TIME": 0,
            "MAGNETIC COMPASS": 298.70238827001,
            "MAGVAR": -11.5,
            "PLANE ALT ABOVE GROUND MINUS CG": 0,
            "PLANE ALTITUDE": 5,
            "PLANE BANK DEGREES": -0.05713413220076,
            "PLANE HEADING DEGREES TRUE": 310.20238827001,
            "PLANE LATITUDE": 36.222370040957,
            "PLANE LONGITUDE": -115.03966501124,
            "PLANE PITCH DEGREES": 0.46066013421995,
            "PLANE TOUCHDOWN LATITUDE": 0,
            "PLANE TOUCHDOWN LONGITUDE": 0,
            "PLANE TOUCHDOWN NORMAL VELOCITY": 0,
            "SEA LEVEL PRESSURE": 2992,
            "SIM ON GROUND": 1,
            "TOTAL WEIGHT": 10000,
            "TRANSPONDER CODE:1": 1200,
            "TRANSPONDER IDENT": 0,
            "TRANSPONDER STATE:1": 4,
            "TYPICAL DESCENT RATE": 2000,
            "VERTICAL SPEED": -1,
            "WHEEL RPM:1": 0,
            "ZULU TIME": 0
        },
        "version": "2.9"
    }
}
```


## Package Files

```
SayIntentionsExport\
	dkjson.lua
	dkjson_readme.txt
	SayIntentionsExport.lua
```

## Usage

* Download the release zip.

* open your DCS scripts folder (depending on whether you use the beta or not) by typing `Windows + R` and pasting in one of the following and clicking OK to open a File Explorer in the correct location:
  * `%UserProfile%\Saved Games\DCS\Scripts`
  * `%UserProfile%\Saved Games\DCS.openbeta\Scripts`

* drag the SayIntentionsExport folder from the release zip into the Scripts folder

* find your Export.lua file and add the following line to the end of the file:

```lua
pcall(function() local dcsSr=require('lfs');dofile(lfs.writedir().."Scripts/SayIntentionsExport/SayIntentionsExport.lua"); end,nil)
```


* startup DCS, choose an aircraft and a starting location (i.e. Nellis, Nevada)

* startup the SayIntentions.ai client application.


## Development

* git clone this repo to a project directory

* remove the 

* start PowerShell in Admin mode to create a symlink:

```
New-Item -ItemType SymbolicLink -Path "%UserProfile%\Saved Games\DCS.openbeta\Scripts\SayIntentionsExport" -Value "path-to-project-dir\dcs-si-exporter\SayIntentionsExport"
```


## License

`SayIntentionsExport.lua` is released via the [MIT License here](./LICENSE).

The `dkjson` package is included as [licensed here](./SayIntentionsExport/dkjson_readme.txt) and distributed with this script. Many thanks to David Heiko Kolf for this lua json library!

* https://github.com/LuaDist/dkjson

