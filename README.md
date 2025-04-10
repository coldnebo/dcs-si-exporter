# dcs-si-exporter

Digital Combat Simulator (DCS) scripts to integrate with [SayIntentions](https://www.sayintentions.ai/) via their [simAPI](https://www.sayintentions.ai/simapi).

The goal is to have working ATC provided by SayIntentions in DCS.

AMAZING!!!

(Thanks to Brian and all the SayIntentions crew for spiking this simAPI so quickly!)


## Current Status

Work in Progress

UPDATE - I figured out how to read the VHF frequency in the F16C. but each plane is different.
Still, for now that means I don't need the "super-hack" anymore.

HACK in Progress -- I have a super hack, which is to read the frequencies from the SI client
and write them back out to the simAPI_input.json until I can source them properly from the
sim.


### MVP Requirements

The following simAPI values are hardcoded currently because I can't find a good source for 
them.  Unfortunately they are the most important required fields from the simAPI specification. 
SayIntentions won't really work without them being dynamic.

```lua
var_data["COM ACTIVE FREQUENCY:1"] = 124.0
var_data["COM ACTIVE FREQUENCY:2"] = 127.5
var_data["COM RECEIVE:1"] = 1
var_data["COM RECEIVE:2"] = 0
var_data["COM TRANSMIT:1"] = 1
var_data["COM TRANSMIT:2"] = 0
var_data["ENGINE TYPE"] = 1 -- Jet
var_data["MAGVAR"] = 0 -- Placeholder
var_data["TRANSPONDER CODE:1"] = 1200
var_data["TRANSPONDER STATE:1"] = 1
```

The most likely source is [DCS-SimpleRadioStandalone](https://github.com/ciribob/DCS-SimpleRadioStandalone/), however the API is GPL 3.0, so we can't just copy from it. Another alternative is to use it, but I can't 
find any exported API from SRS for other mods to use.

I'm still looking for other ways to source this information.


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

