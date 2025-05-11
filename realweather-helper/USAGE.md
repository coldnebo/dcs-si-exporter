
# realweather-helper script

This is a python tool that can be used to configure your [DCS Real Weather](https://github.com/evogelsa/dcs-real-weather) tool.  Make sure you follow the configuration
for real weather BEFORE using this tool.

Requires: Python install for Windows

1. To install the requirements, run:

```
pip install -r requirements.txt
```

2. configure `input.json` [see below](#configure-input-json)

3. then run:

```
python update_realweather.py
```

This will back up the `config.toml` in your DCS Real Weather directory to `config.toml.bak` and create a new `config.toml.template` file. It will then update the original `config.toml` file and run the `realweather.exe` to generate the output mission in your mission folder. 

If you have trouble creating the template, you can [do so manually](#manual-config-template-creation).


## Configure input json

to configure, edit `input.json`:

* find the location of your Missions folder, i.e. `%UserProfile%\Saved Games\DCS.openbeta\Missions\`
* don't forget to double backslash your paths in the input JSON.

```json
{
  "filepaths": {
    "realweather_dir": "D:\\games\\dcs_apps\\realweather_v2.1.1",
    "missons_dir": "%UserProfile%\\Saved Games\\DCS.openbeta\\Missions",
    "input_mission_file": "nellis-ready-f5.miz",
    "output_mission_file": "realweather.miz"
  },
  "map": "Nevada",
  "icao": "KLSV"
}
```

## Manual Config Template Creation

in your `realweather_dir` 

* make a copy of `config.toml` and name it `config.toml.bak`
  * you can preserve any API keys you may have added as part of the DCS Real Weather instructions in the bak.
* make another copy and name it `config.toml.template` -- open this file in an editor and make the following changes:

```diff
--- D:\games\dcs_apps\realweather_v2.1.1\config.toml.bak	Sun May 11 13:05:40 2025
+++ D:\games\dcs_apps\realweather_v2.1.1\config.toml.template	Sun May 11 13:12:28 2025
@@ -11,8 +11,8 @@
 # using a path with backslashes `\`, be sure to escape them with another
 # backslash, e.g. C:\\Users\\myuser\\dcs-missions\\missions.miz.
 [realweather.mission]
-input = "mission.miz"      # path of mission to update
-output = "realweather.miz" # path of updated mission to output
+input = "$input_mission_path"      # path of mission to update
+output = "$output_mission_path" # path of updated mission to output
 
 # These are options for updating the mission brief
 [realweather.mission.brief]
@@ -105,8 +105,8 @@
 # These settings determine how Real Weather will update the mission time
 [options.time]
 enable = true       # set to false to disable updating time
-system-time = false # set to false if you want to use the METAR time
-offset = "0"        # offset system or METAR time by this amount
+system-time = true # set to false if you want to use the METAR time
+offset = "$offset"        # offset system or METAR time by this amount
 
 # These settings determine how Real Weather will update the mission date
 [options.date]
@@ -120,7 +120,7 @@
 
 # the following two options are mutually exclusive, pick one to use. If both are
 # configured, icao will be used
-icao = "UGKO"  # Airport ICAO to retrieve METAR information from
+icao = "$icao"  # Airport ICAO to retrieve METAR information from
 icao-list = [] # List of ICAOs, randomly selects one to retrieve METAR from
 
 runway-elevation = 160 # meters, used for adjusting cloud heights and wind calc
```

