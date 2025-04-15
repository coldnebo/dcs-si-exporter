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

* Aircraft Supported
  * `F-16C_50`
  * `FA-18C_hornet`
  * `F-5E-3`


 ### Input Data

* All required fields implemented or hardcoded for now.
* only COM1 supported 
* only VHF radio mapped to COM1
* COM2 disabled
* transponder mode3 code now supported and hardcoded ALT on.


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
  * [DONE] read from F-16C
  * [TODO] lookup for other aircraft
  * can be hacked by writing `{"setvar":"XPNDR_SET","value":"1114"}` into simAPI_output.jsonl

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


## Thank You

Thanks to SRS, DCS-BIOS and MOOSE for their projects.

[DCS Simple Radio Standalone](https://github.com/ciribob/DCS-SimpleRadioStandalone) provided insight as to 
how to dig into DCS structures. I directly adapted some of the details in the aircraftapi and reference 
that project in the License below.

I haven't used the following directly for implementation, but they are on the short list of must-have 
resources for DCS programming:

[DCS-BIOS](https://github.com/DCS-Skunkworks/dcs-bios) because they 
are a key source in many of the SRS files.  I haven't used their debugging and exploration tool yet, but 
I am convinced that it is probably the only way to systematically explore and reverse engineer the internal
apis in DCS.

[MOOSE](https://github.com/FlightControl-Master/MOOSE) has information that has been helpful.



## License

`SayIntentionsExport.lua` is released via the [GPLv3 License here](./SayIntentionsExport/dcs-si-exporter-LICENSE.txt).  This is now included with the redistribution zip.

* 2025-04-13 Why did you change your license?

Because while I did not copy code verbatim from the DCS SRS project, there were several times I did deep 
dives into that project to understand the low level apis in DCS, so I want to more formally credit Ciran Fisher
and the contributors to SRS for their hard work.


### dkjson

* MIT License

The `dkjson` package is included as [licensed here](./SayIntentionsExport/dkjson_readme.txt) and distributed with this script for reading and writing JSON formats from lua. Many thanks to David Heiko Kolf for this lua json library!

* https://github.com/LuaDist/dkjson


### DCS-SimpleRadioStandalone

* GPLv3 License

The aircraftapi portion of this library was informed heavily by [DCS Simple Radio Standalone](https://github.com/ciribob/DCS-SimpleRadioStandalone), so while I did
not copy code from that project, I did discover data structures and access from that project and want to recognize
Ciaran Fisher for the hard work in discovering those undocumented APIs from various other people in the DCS community. 

For example, I never would have figured out how to read the F/A-18 scratchpad for the mode3 IFF transponder code
as quickly. This saved a large amount of trial and error, so I changed my license to match his and reference
where I adapted code from that project for `aircraftapi.lua`.

* https://github.com/ciribob/DCS-SimpleRadioStandalone



