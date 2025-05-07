# dcs-si-exporter

Digital Combat Simulator (DCS) scripts to integrate with [SayIntentions](https://www.sayintentions.ai/) via their [simAPI](https://www.sayintentions.ai/simapi).

The goal is to have working ATC provided by SayIntentions in DCS.

AMAZING!!!

(Thanks to Brian and all the SayIntentions crew for spiking this simAPI so quickly!)


## Table of Contents

* [Current Status](#current-status)
  * [MVP Requirements](#mvp-requirements)
* [Package Files](#package-files)
* [Usage](#usage)
  * [Optional DCS RealWeather](#optional-dcs-weather)
* [Input Date](#input-data)
* [Development](#development)
* [Thank You](#thank-you)
* [License](#license)
  * [dkjson](#dkjson)
  * [DCS-SimpleRadioStandalone](#dcs-simpleradiostandalone)
  * [dcs-real-weather](#dcs-real-weather)



## Current Status

Open Beta

All the required features to support simAPI are available in the supported maps and aircraft.

Please give feedback and issues in [Discussions](https://github.com/coldnebo/dcs-si-exporter/discussions)
first to give us a chance to provide answers for common problems. Bugs will be split off and tracked in [Issues](https://github.com/coldnebo/dcs-si-exporter/issues).  Please read the current features and limitations before 
creating issues. 

Thanks!


### MVP Requirements

Features and Current Status:

* implement [SayIntensions simAPI](https://sayintentionsai.freshdesk.com/support/solutions/articles/154000221017-simapi-developer-howto-integrating-sayintentions-ai-with-any-flight-simulator)
  * `simAPI_input.json` - input to the SayIntentions client from this exporter
    * [DONE] setup default structure, required and optional parameters and types
    * All required fields implemented or hardcoded for now.
    * only COM1 supported 
    * only VHF radio mapped to COM1
    * COM2 disabled
    * transponder mode3 code now supported and hardcoded ALT on.

  * `simAPI_output.jsonl` - output from the SayIntensions client to this exporter (append on update)
  	* [DONE] clear after read
    * can set COM1 from SayIntentions client / AI CoPilot

* Aircraft Supported
  * `F-16C_50`
  * `FA-18C_hornet`
  * `F-5E-3`

* Maps Supported
  * Caucasus
  * Marianas
  * Nevada
  * Persian Gulf




## Package Files

```
SayIntentionsExport\
  aircraftapi.lua
  dcs-si-exporter-LICENSE.txt
  dkjson.lua
  dkjson_readme.txt
  mapapi.lua
  realweatherapi.lua
  SayIntentionsExport.lua
  simapi.lua
```

## Usage

1. Download the [latest release](https://github.com/coldnebo/dcs-si-exporter/releases) zip.

2. open your DCS scripts folder (depending on whether you use the beta or not) by typing `Windows + R` and 
   pasting in one of the following and clicking OK to open a File Explorer in the correct location:

     * `%UserProfile%\Saved Games\DCS\Scripts`
     * `%UserProfile%\Saved Games\DCS.openbeta\Scripts`

3. drag the `SayIntentionsExport` folder from the release zip into the `Scripts` folder.

4. in the `Scripts` folder, find your `Export.lua` file and add the following line to the end of the file:

    ```lua
    pcall(function() local dcsSr=require('lfs');dofile(lfs.writedir().."Scripts/SayIntentionsExport/SayIntentionsExport.lua"); end,nil)
    ```

5. startup DCS, choose an aircraft and a starting location (i.e. F-16, Nellis, Nevada)

   once the simulation is running you should see the following files in the following locations which
   will let you know the program is running:

    * `%LOCALAPPDATA%\SayIntentionsAI\dcs-si-exporter_debug.txt`
    * `%LOCALAPPDATA%\SayIntentionsAI\simAPI_input.json`

   you can check the `dcs-si-exporter_debug.txt` for any errors if things seem to not be working.

6. startup the SayIntentions.ai client application. you should additionally see this file appear: 

    * `%LOCALAPPDATA%\SayIntentionsAI\simAPI_output.jsonl`

Congratulations, if you see those files your install should be working. You can try VFR or IFR flights. 

Nellis (KLSV) to Laughlin (KIFP) is a good IFR flight as both are towered airports.


### Optional DCS RealWeather

If you have the [DCS RealWeather](https://github.com/evogelsa/dcs-real-weather) tool, you can 
generate a mission using real weather. [Follow the directions](https://github.com/evogelsa/dcs-real-weather/blob/main/cmd/realweather/README.md) 
in that project to install and setup your directory. 

After the first time you run the app it will generate a file `realweather.log` containing information that this mod can read.

Open the file `%UserProfile%\Saved Games\DCS.openbeta\Scripts\SayIntentionsExport\realweatherapi.lua` and set the directory for 
the `realweather.log` location, for example:

```lua
-- Path to the log file (you can change this if needed)
local log_path = [[D:\games\dcs_apps\realweather_v2.1.1\realweather.log]]
```

This will allow ATC to report real world baro pressure.

To use this, you would follow these steps before the flight:

1. edit `config.toml` to point at a mission map with a player aircraft setup per the DCS realweather instructions.
2. run `realweather.exe` to fetch the current weather and write the `realweather.log` file.
3. start DCS and load the generated `realweather` mission created from your `config.toml` configuration. 


## Input Data

* [TODO] Optional fields?
  * `ZULU TIME` and `LOCAL TIME` maybe from mission data?

* `COM ACTIVE FREQUENCY:1` 
  * support 8.333KHz channel spacing
  * read from supported aircraft

* `MAGVAR`
  * looked up average per map. see `mapapi.lua`.

* `PLANE ALT ABOVE GROUND MINUS CG`
  * F-16C seems to be 5 feet above the ground when on the ground so hard-coded offset -5.
  * [TODO] per plane map of offsets? some other way to determine `SIM_ON_GROUND` ?

* `SEA LEVEL PRESSURE`
  * [OPTIONAL] Reading from [DCS Real Weather mod](https://github.com/evogelsa/dcs-real-weather)
  * defaults to 29.92 if not using real-weather.

* `TRANSPONDER CODE:1`
  * can be set from SayIntentions Client by clicking on frequencies
  * read from supported aircraft

* `TRANSPONDER IDENT` - NA
  * [TODO] implement? not sure where this function is in various aircraft?

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
            "AIRSPEED INDICATED": 0,
            "AIRSPEED TRUE": 0,
            "AMBIENT WIND DIRECTION": 0,
            "AMBIENT WIND VELOCITY": 0,
            "CIRCUIT COM ON:1": 1,
            "CIRCUIT COM ON:2": 1,
            "COM ACTIVE FREQUENCY:1": 305,
            "COM ACTIVE FREQUENCY:2": 100,
            "COM RECEIVE:1": 1,
            "COM RECEIVE:2": 0,
            "COM TRANSMIT:1": 1,
            "COM TRANSMIT:2": 0,
            "ELECTRICAL MASTER BATTERY:0": 1,
            "ENGINE TYPE": 1,
            "INDICATED ALTITUDE": 1863,
            "LOCAL TIME": 0,
            "MAGNETIC COMPASS": 347.76334466074,
            "MAGVAR": -11.5,
            "PLANE ALT ABOVE GROUND MINUS CG": 0,
            "PLANE ALTITUDE": 5,
            "PLANE BANK DEGREES": 0.028837929124707,
            "PLANE HEADING DEGREES TRUE": 359.26334466074,
            "PLANE LATITUDE": 36.245992971049,
            "PLANE LONGITUDE": -115.03428511504,
            "PLANE PITCH DEGREES": -0.66272188930467,
            "PLANE TOUCHDOWN LATITUDE": 0,
            "PLANE TOUCHDOWN LONGITUDE": 0,
            "PLANE TOUCHDOWN NORMAL VELOCITY": 0,
            "SEA LEVEL PRESSURE": 2989,
            "SIM ON GROUND": 1,
            "TOTAL WEIGHT": 24675,
            "TRANSPONDER CODE:1": 0,
            "TRANSPONDER IDENT": 0,
            "TRANSPONDER STATE:1": 4,
            "TYPICAL DESCENT RATE": 2000,
            "VERTICAL SPEED": 0,
            "WHEEL RPM:1": 0,
            "ZULU TIME": 0
        },
        "version": "2.9"
    }
}
```




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


### dcs-real-weather

If you are using DCS real Weather mod, this mod can read that 
baro pressure setting and use it. otherwise baro defaults to 29.92.

* https://github.com/evogelsa/dcs-real-weather
