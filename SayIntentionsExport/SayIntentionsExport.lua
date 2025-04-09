
package.path = package.path .. ";" .. lfs.writedir() .. "Scripts\\SayIntentionsExport\\?.lua"

local sayintentions_path = os.getenv("LOCALAPPDATA") .. "\\SayIntentionsAI\\"

local simapi_input_file = sayintentions_path .. "simAPI_input.json"
local simapi_output_file = sayintentions_path .. "simAPI_output.jsonl"
local simapi_debug_file = sayintentions_path .. "dcs-si-exporter_debug.txt"


local function log_marker(msg)
    local log = io.open(simapi_debug_file, "a")
    log:write("dcs-si-exporter: [" .. msg .. "] reached at " .. os.date() .. "\n")
    log:close()
end

local function safe_require(library)
    log_marker("loading " .. library )
    local libraryOK, libraryObj = pcall(require, library)
    if not libraryOK then
        log_marker("FAILED to load " .. library .. ".lua with error: " .. tostring(libraryObj))
        libraryObj = nil
    end
    return libraryObj
end



log_marker("top of file")

local lfs = safe_require("lfs")
local json = safe_require("dkjson")
local simapi = safe_require("simapi")



log_marker("defining getTelemetry()")
local function getTelemetry()
    local data, var_data, sim_data

    data, var_data, sim_data = simapi.default_input()


    log_marker("starting getTelemetry collection")
    -- These functions are available from the DCS Lua environment:
    if LoGetSelfData then
        local selfData = LoGetSelfData()
        if selfData then
            var_data["PLANE LATITUDE"] = selfData.LatLongAlt.Lat
            var_data["PLANE LONGITUDE"] = selfData.LatLongAlt.Long
            var_data["PLANE ALTITUDE"] = math.floor(selfData.LatLongAlt.Alt)
            var_data["PLANE HEADING DEGREES TRUE"] = math.floor(selfData.Heading)
        end
    end

    if LoGetIndicatedAirSpeed then
        var_data["AIRSPEED INDICATED"] = math.floor(LoGetIndicatedAirSpeed() * 1.94384) -- m/s to knots
    end

    if LoGetTrueAirSpeed then
        var_data["AIRSPEED TRUE"] = math.floor(LoGetTrueAirSpeed() * 1.94384)
    end

    if LoGetAltitudeAboveGroundLevel then
        var_data["PLANE ALT ABOVE GROUND MINUS CG"] = math.floor(LoGetAltitudeAboveGroundLevel())
    end

    if LoGetADIPitchBankYaw then
        local ok3, pitch, bank, yaw = pcall(LoGetADIPitchBankYaw)
        if ok3 then
            var_data["PLANE PITCH DEGREES"] = math.floor(pitch)
            var_data["PLANE BANK DEGREES"] = math.floor(bank)
        else
            log_marker("LoGetADIPitchBankYaw() failed")
        end
    end

    var_data["INDICATED ALTITUDE"] = var_data["PLANE ALTITUDE"]
    var_data["ENGINE TYPE"] = 1 -- Jet
    var_data["MAGNETIC COMPASS"] = var_data["PLANE HEADING DEGREES TRUE"]
    

    -- SUPER HACK!!! use the SI client to select the frequencies, then reflect them 
    -- back into the output until we figure out how to read the aircraft radios!
    local siout = simapi.fetch_output(json, simapi_output_file)


    -- Hardcoded or placeholder values for now

    -- we need sources for all these:
    var_data["COM ACTIVE FREQUENCY:1"] = siout["COM_RADIO_SET_HZ"] / 1000000
    var_data["COM RECEIVE:1"] = 1
    var_data["COM TRANSMIT:1"] = 1
    var_data["MAGVAR"] = 0 -- Placeholder
    var_data["TRANSPONDER CODE:1"] = siout["XPNDR_SET"] or 1200
    var_data["TRANSPONDER STATE:1"] = 1


    -- SEA LEVEL PRESSURE (in millibars)
    -- There is no direct call for QNH, so default to 1013.25 or use mission weather if you pull it via mission scripting later
    var_data["SEA LEVEL PRESSURE"] = 1013  -- standard ISA value, rounded

    -- SIM ON GROUND
    -- Redundant with PLANE TOUCHDOWN, but make it explicit
    --log_marker("PLANE ALT ABOVE GROUND MINUS CG (" .. var_data["PLANE ALT ABOVE GROUND MINUS CG"] .. ")")
    local plane_on_ground = var_data["PLANE ALT ABOVE GROUND MINUS CG"] <= 1 and 1 or 0
    var_data["SIM ON GROUND"] = plane_on_ground

    -- TOTAL WEIGHT (in lbs or kg – DCS returns kg)
    if LoGetWeight then
        local ok, weight = pcall(LoGetWeight)
        if ok and weight then
            var_data["TOTAL WEIGHT"] = math.floor(weight)  -- kg
        else
            var_data["TOTAL WEIGHT"] = nil
        end
    end

    -- VERTICAL SPEED (in feet per minute)
    if LoGetVerticalVelocity then
        local ok, vSpeed = pcall(LoGetVerticalVelocity)
        if ok and vSpeed then
            var_data["VERTICAL SPEED"] = math.floor(vSpeed * 196.850394)  -- m/s to ft/min
        else
            var_data["VERTICAL SPEED"] = nil
        end
    end

    -- WHEEL RPM (approximate placeholder)
    -- No direct access to wheel rotation in DCS API; use 0 if in air
    var_data["WHEEL RPM"] = plane_on_ground == 1 and 150 or 0  -- crude estimate



    -- Metadata
    sim_data["name"] = "DCS World"
    sim_data["version"] = "2.9"
    sim_data["adapter_version"] = "0.1"
    sim_data["simapi_version"] = "1.0"
    sim_data["exe"] = "DCS.exe"

    log_marker("finished getTelemetry data collection")

    return data
end



log_marker("defining SayIntentionsExport")
function SayIntentionsExport()
    log_marker("getTelemetry() called")
    local ok, telemetry = pcall(getTelemetry)

    if not ok then
        log_marker("ERROR in getTelemetry: " .. tostring(telemetry))
        return
    end
    
    log_marker("writing telemetry")
    local file = io.open(simapi_input_file, "w")
    if file then
        file:write(json.encode(telemetry))
        file:close()
    else
        log_marker("Failed to open simAPI_input.json for writing")
    end
end


local oldLuaExportAfterNextFrame = LuaExportAfterNextFrame

local ExportInterval = 2.0  -- seconds
local LastExportTime = 0

function LuaExportAfterNextFrame()
    if oldLuaExportAfterNextFrame then oldLuaExportAfterNextFrame() end
    local currentTime = LoGetModelTime()
    if currentTime and (currentTime - LastExportTime) >= ExportInterval then
        SayIntentionsExport()
        LastExportTime = currentTime
    end
end



