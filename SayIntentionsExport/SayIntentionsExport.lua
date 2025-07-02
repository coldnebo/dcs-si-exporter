
    -- SayIntentions Digital Combat Simulator exporter

    -- Copyright (C) 2025  Larry Kyrala

    -- This program is free software: you can redistribute it and/or modify
    -- it under the terms of the GNU General Public License as published by
    -- the Free Software Foundation, either version 3 of the License, or
    -- (at your option) any later version.

    -- This program is distributed in the hope that it will be useful,
    -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- GNU General Public License for more details.

    -- You should have received a copy of the GNU General Public License
    -- along with this program.  If not, see <https://www.gnu.org/licenses/>.


package.path = package.path 
    .. ";" .. lfs.writedir() .. [[Mods\Services\SayIntentionsExport\?.lua]]
    .. ";" .. lfs.writedir() .. [[Mods\Services\SayIntentionsExport\aircraft\?.lua]]


-- siexporter object attributes and methods

siexporter = {}

siexporter.sayintentions_path = os.getenv("LOCALAPPDATA") .. [[\SayIntentionsAI\]]
siexporter.log_path = siexporter.sayintentions_path .. "dcs-si-exporter.log"
    
function siexporter:log(msg)
    local log_file = io.open(self.log_path, "a")
    log_file:write("dcs-si-exporter: [" .. msg .. "] reached at " .. os.date() .. "\n")
    log_file:close()
end

function siexporter:clear_log_file()
    local log_file, cerr = io.open(self.log_path, "w")
    if not log_file then
        error("Failed to clear file: " .. tostring(cerr))
    end
    log_file:close()
end

function siexporter:safe_require(library)
    self:log("loading " .. library )
    local libraryOK, libraryObj = pcall(require, library)
    if not libraryOK then
        self:log("FAILED to load " .. library .. ".lua with error: " .. tostring(libraryObj))
        libraryObj = nil
    end
    return libraryObj
end


siexporter:clear_log_file()
siexporter:log("top of file")


--dkjson = siexporter:safe_require("dkjson")
--siexporter:log(tostring(dkjson))


local ok, result = pcall(function()
    return siexporter.safe_require(siexporter, "dkjson")
end)

if not ok then
    siexporter:log("safe_require for dkjson threw error: " .. tostring(result))
else
    dkjson = result
    siexporter:log("safe_require returned: " .. tostring(dkjson))
end



-- local simapi_input_file = sayintentions_path .. "simAPI_input.json"
-- local simapi_output_file = sayintentions_path .. "simAPI_output.jsonl"
-- local simapi_debug_file = sayintentions_path .. "dcs-si-exporter_debug.txt"



-- -- clear debug log on start
-- local clear_file, cerr = io.open(simapi_debug_file, "w")
-- if not clear_file then
--     error("Failed to clear file: " .. tostring(cerr))
-- end
-- clear_file:close()


-- local function log_marker(msg)
--     local log = io.open(simapi_debug_file, "a")
--     log:write("dcs-si-exporter: [" .. msg .. "] reached at " .. os.date() .. "\n")
--     log:close()
-- end


-- local function safe_require(library)
--     log_marker("loading " .. library )
--     local libraryOK, libraryObj = pcall(require, library)
--     if not libraryOK then
--         log_marker("FAILED to load " .. library .. ".lua with error: " .. tostring(libraryObj))
--         libraryObj = nil
--     end
--     return libraryObj
-- end







-- REFACTORING MARKER: UP TO HERE

--local dkjson = safe_require("dkjson")


-- local simapi = safe_require("simapi")
-- local aircraft_api = safe_require("aircraftapi")
-- local mapapi = safe_require("mapapi")
-- local weather = require("realweatherapi")

-- -- persist xpdr between telemetry calls
-- local xpdr




-- log_marker("defining getTelemetry()")
-- local function getTelemetry()
--     local data, var_data, sim_data
--     data, var_data, sim_data = simapi.default_input()

--     --log_marker("starting getTelemetry collection")

--     -- no longer a hack, we need to legitimately support when the SI client 
--     -- updates the data. for example, clicking the freq in the client, or 
--     -- asking the AI copilot to handle the frequencies.
--     local siout = simapi.fetch_output(dkjson, simapi_output_file)

--         -- ===== REQUIRED VARIABLES =====

--     local pitch, bank, yaw = LoGetADIPitchBankYaw()

--     -- REQUIRED:INSTRUMENTS

--     var_data["AIRSPEED INDICATED"] = math.floor(LoGetIndicatedAirSpeed() * 1.94384) -- m/s to knots
    

--     -- identify the unit name/type    
--     local aircraft_type = LoGetSelfData().Name
    
--     -- VHF read/write 
--     -- we can only support VHF, so let's use COM1 only (UHF not supported yet)    
--     if siout["COM_RADIO_SET_HZ"] then
--         aircraft_api.set_vhf_frequency(aircraft_type, siout["COM_RADIO_SET_HZ"])
--     end
--     local freq = aircraft_api.get_vhf_frequency(aircraft_type)

--     -- TRANSPONDER read/write
--     if siout["XPNDR_SET"] then 
--         aircraft_api.set_mode3_code(aircraft_type, siout["XPNDR_SET"])
--     end
--     -- transponder code is only visible in FA18 when setting it in the UFC, so we have to hoist this and
--     -- persist it.
--     xpdr = aircraft_api.get_mode3_code(aircraft_type) or xpdr

   
--     var_data["COM ACTIVE FREQUENCY:1"] = (freq / 1e6)
--     -- siout["COM_RADIO_SET_HZ"] / 1000000     -- (FLOAT) The current value of the COM1 Active Frequency, in MHz.  Example value:  118.32
    
--     -- enable COM1 for RX and TX
--     var_data["COM RECEIVE:1"] = 1                   -- (INT) Indicates whether the COM1 Speaker is on or off. Possible values are 1 or 0.
--     var_data["COM TRANSMIT:1"] = 1                  -- (INT) Indicates whether COM1 is currently the active radio (theone that will transmit if the pilot presses the PTT button). Possible values are 1 or 0.
    
--     var_data["INDICATED ALTITUDE"] = math.floor(LoGetSelfData().LatLongAlt.Alt * 3.28084)  -- meters to feet  -- math.floor(LoGetAltitudeAboveSeaLevel() * 3.28084)    -- meters to feet



--     var_data["TRANSPONDER CODE:1"] = xpdr              -- (INT) The currently indicated 4-digit transponder code.  (Example: 2543)

    
--     -- REQUIRED:TELEMETRY

--     var_data["AIRSPEED TRUE"] = math.floor(LoGetTrueAirSpeed() * 1.94384) -- m/s to knots
    
--     var_data["PLANE ALTITUDE"] = math.floor(LoGetAltitudeAboveGroundLevel() * 3.28084)  -- meters to feet                  -- (INT) The altitude of the plane, above sea level, measured in feet.
--     var_data["PLANE ALT ABOVE GROUND MINUS CG"] = (var_data["PLANE ALTITUDE"] - 5)  -- 5 feet estimate hack  -- same -- (INT) The altitude of the plane, above the surface beneath it, measured in feet. If the aircraft is on the ground, this should be 0.
--     var_data["PLANE BANK DEGREES"] = math.deg(bank)  -- rad to deg           -- (INT) Current turn angle of the airplane as a positive or negative number. Example: -15 (15 degree turn to the left)
--     var_data["PLANE HEADING DEGREES TRUE"] = math.deg(LoGetSelfData().Heading)  -- rad to deg    -- (INT) True heading of the airplane, after accounting for magnetic variation
--     var_data["PLANE LATITUDE"] = LoGetSelfData().LatLongAlt.Lat              -- (FLOAT) Current latitude of the airplane, as a decimal.
--     var_data["PLANE LONGITUDE"] = LoGetSelfData().LatLongAlt.Long              -- (FLOAT) Current longitude of the airplane, as a decimal.
--     var_data["PLANE PITCH DEGREES"] = math.deg(pitch)  -- rad to deg            -- (INT) Current pitch angle of the airplane, in degrees, as a positive or number number. Example:  -15 indicates a 15-degree downward pitch.

--     local lat = var_data["PLANE LATITUDE"]
--     local long = var_data["PLANE LONGITUDE"]
--     --log_marker("lat/long " .. lat .. " , " .. long)

--     var_data["MAGVAR"] = mapapi.getMagVarByLocation(lat, long)     -- (INT) The magnetic variation at the current position of the aircraft. This will be added to the current heading to get a true heading, thus negative numbers may be used where appropriate. Example value:  -12
--     var_data["MAGNETIC COMPASS"] = math.deg(yaw) + var_data["MAGVAR"] -- rad to deg + magvar                -- (INT) The indicated heading, in degrees
    

    

--     local pressure, err = weather.get_pressure()
--     if pressure then
--         --log_marker("Pressure * 100 (inHg x100):" .. pressure)
--     else
--         pressure = 2992
--         --log_marker("Error:" .. err)
--     end


--     var_data["SEA LEVEL PRESSURE"] = pressure    -- inMG standard. can't get a good read on this either? mission data?
--     -- math.floor(seaLevelPressure * 0.02953 * 100.0) -- millibars to inHG * 100              -- (INT) Current barometric pressure, measured in inHG. Example:  2991
    
--     var_data["SIM ON GROUND"] = var_data["PLANE ALT ABOVE GROUND MINUS CG"] <= 1 and 1 or 0                   -- (INT) Indicates whether or not the aircraft is currently on the ground. Possible values are 1 or 0.

--     var_data["TOTAL WEIGHT"] = aircraft_api.get_motw(aircraft_type)             -- (INT) Total weight (in pounds) of the aircraft and all onboard fuel, passengers, and cargo.
--     var_data["VERTICAL SPEED"] = math.floor(LoGetVerticalVelocity() * (3.28084 * 60.0))  -- meters/sec to feet/min                  -- (INT) Current vertical speed in feet per minute, expressed as a positive or negative number.

--     var_data["WHEEL RPM:1"] = var_data["SIM ON GROUND"] == 1 and var_data["AIRSPEED TRUE"] or 0        -- guesstimate             -- (INT) Current speed (in revolutions per minute) of any other wheel.  (This can be the same as WHEEL RPM:0 if you want).

--     -- REQUIRED:AIRCRAFT DETAILS


--     var_data["ENGINE TYPE"] = aircraft_api.get_engine_type(aircraft_type)               -- (INT) Engine type, as an integer. 0 = Piston, 1 = Jet, 2 = None, 3 = Helo(Bell) turbine, 4 = Unsupported, 5 = Turboprop


--     --log_marker("finished getTelemetry data collection")
--     return data
-- end



-- log_marker("defining SayIntentionsExport")
-- function SayIntentionsExport()
--     --log_marker("getTelemetry() called")
--     local ok, telemetry = pcall(getTelemetry)

--     if not ok then
--         log_marker("ERROR in getTelemetry: " .. tostring(telemetry))
--         return
--     end
    
--     --log_marker("writing telemetry")
--     local file = io.open(simapi_input_file, "w")
--     if file then
--         file:write(dkjson.encode(telemetry))
--         file:close()
--     else
--         log_marker("Failed to open simAPI_input.json for writing")
--     end
-- end


-- local oldLuaExportAfterNextFrame = LuaExportAfterNextFrame

-- local ExportInterval = 2.0  -- seconds
-- local LastExportTime = 0

-- function LuaExportAfterNextFrame()
--     if oldLuaExportAfterNextFrame then oldLuaExportAfterNextFrame() end
--     local currentTime = LoGetModelTime()
--     if currentTime and (currentTime - LastExportTime) >= ExportInterval then
--         SayIntentionsExport()
--         LastExportTime = currentTime
--     end
-- end



