
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

-- Now set package paths relative to this
package.path = package.path 
    .. ";" .. _G.SIEXPORT_BASE_DIR .. [[?.lua]]
    .. ";" .. _G.SIEXPORT_BASE_DIR .. [[aircraft\?.lua]]

-- siexporter object attributes and methods

_G.siexporter = dofile(_G.SIEXPORT_BASE_DIR .. [[si_config.lua]])

siexporter.log_path = siexporter.sayintentions_path .. "dcs-si-exporter.log"

function siexporter:log(msg)
    if self.log_file then
        self.log_file:write("dcs-si-exporter: [" .. tostring(msg) .. "] reached at " .. os.date() .. "\n")
    else
        print("LOGGER FAILURE: log_file not initialized")
    end
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

function siexporter:safe_call(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        siexporter:log("safe_call error: " .. tostring(result))
        return nil
    else
        --siexporter:log("safe_call returned: " .. tostring(result))
        return result
    end
end


siexporter:clear_log_file()
siexporter.log_file = io.open(siexporter.log_path, "a")
siexporter:log("top of file")
siexporter:log("SIEXPORT_BASE_DIR: '" .. _G.SIEXPORT_BASE_DIR .. '"')



dkjson = siexporter:safe_require("dkjson")
local simapi = siexporter:safe_require("simapi")
local weather = siexporter:safe_require("realweatherapi")


-- load the aircraft type
local aircraft_type = LoGetSelfData().Name
local aircraft = siexporter:safe_require(aircraft_type)
if aircraft == nil then
    siexporter:log("no aircraft found for '" .. aircraft_type .. "', using default generic.")
    local Aircraft = siexporter:safe_require("aircraft") -- or adjust path if needed 
    aircraft = Aircraft:new()
end


-- persist xpdr between telemetry calls
local xpdr
local last_on_ground = false

-- we try to fetch baro from realweather if it's configured...
local pressure, pressure_err = weather.get_pressure()

function map_data_to_simapi()
    --siexporter:log("map_data_to_simapi")

    simapi.input["AIRSPEED INDICATED"] = aircraft:indicated_airspeed_knots()
    simapi.input["AIRSPEED TRUE"] = aircraft:true_airspeed_knots()

    -- COM1 radios (most aircaft in DCS have only one VHF radio)
    -- FREQ always set before get!
    if simapi.output["COM_RADIO_SET_HZ"] then
        aircraft:set_vhf_frequency(simapi.output["COM_RADIO_SET_HZ"])
    end
    simapi.input["COM ACTIVE FREQUENCY:1"] = (aircraft:get_vhf_frequency() / 1e6)
    -- enable RX and TX
    simapi.input["COM RECEIVE:1"] = 1
    simapi.input["COM TRANSMIT:1"] = 1  

    -- skipping COM2 because the other radio is UHF which isn't modeled in SI yet.

    simapi.input["ENGINE TYPE"] = aircraft:get_engine_type()

    -- supposed to be msl

    simapi.input["INDICATED ALTITUDE"] = aircraft:indicated_altitude()

    simapi.input["MAGNETIC COMPASS"] = aircraft:magnetic_heading()

    local lat = aircraft:position().lat
    local long = aircraft:position().long


    -- we don't need the mapapi after all -- YAY 
    -- this will work on EVERY map now. EXCELLENT!
    simapi.input["MAGVAR"] = aircraft:magnetic_heading() - aircraft:true_heading()


    --siexporter:log("agl: " .. tostring(aircraft:altitude_agl()))
    --siexporter:log("cg_height is: " .. tostring(aircraft.cg_height))
    local altitude_minus_cg = aircraft:altitude_agl() - aircraft:cg_height()

    simapi.input["PLANE ALT ABOVE GROUND MINUS CG"] = altitude_minus_cg
    local on_ground = (altitude_minus_cg <= 0)

    -- geometric altitude (baro irrelevant)
    --siexporter:log("aircraft:altitude_msl() : " .. tostring(aircraft:altitude_msl() or "nil"))
    simapi.input["PLANE_ALTITUDE"] = aircraft:altitude_msl()

    simapi.input["PLANE BANK DEGREES"] = aircraft:bank()

    simapi.input["PLANE HEADING DEGREES TRUE"] = aircraft:true_heading()

    simapi.input["PLANE LATITUDE"] = lat 
    simapi.input["PLANE LONGITUDE"] = long

    simapi.input["PLANE PITCH DEGREES"] = aircraft:pitch()

    if pressure_err then 
        -- otherwise we try to get the internal impl (seems to always be nil?) or return standard (29.92)
        pressure = aircraft:sea_level_pressure()
    end
    simapi.input["SEA LEVEL PRESSURE"] = pressure

    if on_ground then 
        simapi.input["SIM ON GROUND"] = 1
    else
        simapi.input["SIM ON GROUND"] = 0
    end

    simapi.input["TOTAL WEIGHT"] = aircraft:total_weight()

    -- transponder code is only visible in FA18 when setting it in the UFC, so we have to hoist this and
    -- persist it.
    if simapi.output["XPNDR_SET"] then
        aircraft:set_mode3_code(simapi.output["XPNDR_SET"])
    end
    xpdr = aircraft:get_mode3_code() or xpdr
    simapi.input["TRANSPONDER CODE:1"] = xpdr


    simapi.input["VERTICAL SPEED"] = aircraft:vertical_speed()

    if on_ground then 
        simapi.input["WHEEL RPM:1"] = aircraft:wheel_rpm()
    end

    simapi.input["AMBIENT WIND DIRECTION"] = aircraft:wind_degrees_true()
    simapi.input["AMBIENT WIND VELOCITY"] = aircraft:wind_knots()

    -- defaults for unsupported options
    simapi.input["CIRCUIT COM ON:1"] = 1
    simapi.input["ELECTRICAL MASTER BATTERY:0"] = 1
    
    -- LoGetMissionStartTime() is returning nil in exporter context.
    --simapi.output["LOCAL TIME"] = LoGetMissionStartTime()

    -- if we can figure out the latch for SIM ON GROUND then this could also be triggered
    -- with whatever the current setting of lat long is.
    if on_ground and last_on_ground then
        simapi.input["PLANE TOUCHDOWN LATITUDE"] = lat
        simapi.input["PLANE TOUCHDOWN LONGITUDE"] = long
        simapi.input["PLANE TOUCHDOWN NORMAL VELOCITY"] = aircraft:vertical_speed()
    end
    
    last_on_ground = on_ground

    -- another example of a signal, not sure how long this lasts, may need to be hoisted
    -- if the interval is shorter than the sampling interval.
    simapi.input["TRANSPONDER IDENT"] = aircraft:transponder_ident()

    simapi.input["TRANSPONDER STATE:1"] = aircraft:transponder_state()

    simapi.input["TYPICAL DESCENT RATE"] = aircraft:typical_descent_rate()

    -- not sure what mission start time is in yet. could be seconds since midnight or 
    -- something else. let's find out and then fix local and zulu accordingly if possible
    -- if not, these are optional and can be nil to disable.
    simapi.input["ZULU TIME"] = LoGetMissionStartTime()
end



-- main export function
function SayIntentionsExport()
    -- siexporter:log("running SayIntentionsExport")
    -- first read and clear output file
    simapi:read_si_output()
    -- then map data
    siexporter:safe_call(function() return map_data_to_simapi() end)
    -- then write output file
    simapi:write_si_input()
end


local oldLuaExportAfterNextFrame = LuaExportAfterNextFrame

local ExportInterval = 2.0  -- seconds
local LastExportTime = 0

-- timed export loop (every interval)
function LuaExportAfterNextFrame()
    if oldLuaExportAfterNextFrame then oldLuaExportAfterNextFrame() end
    local currentTime = LoGetModelTime()
    if currentTime and (currentTime - LastExportTime) >= ExportInterval then
        SayIntentionsExport()
        LastExportTime = currentTime
    end
end


function LuaExportStop()
    if siexporter.log_file then
        siexporter.log_file.close()
        siexporter.log_file = nil
    end
end

