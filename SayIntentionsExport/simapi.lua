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


-- This module abstracts the simapi interface and controls read and write from
-- the SayIntentions client via the input and output files.
--
-- NOTE: "input" and "output" are defined from the perspective of the 
-- SayIntentions client and not that of the siexporter.


local simapi = {
	input = {
		-- REQUIRED
		["AIRSPEED INDICATED"] = 0,  		-- Indicated Airspeed in Knots
		["AIRSPEED TRUE"] = 0,          	-- True (Ground) Airspeed in Knots
		["COM ACTIVE FREQUENCY:1"] = 0.0,  	-- The current value of the COM1 Active Frequency, in MHz.  Example value:  118.32
		["COM ACTIVE FREQUENCY:2"] = 0.0,	-- The current value of the COM2 Active Frequency, in MHz.  Example value:  132.14
		["COM RECEIVE:1"] = 0,				-- Indicates whether the COM1 Speaker is on or off. Possible values are 1 or 0.
		["COM RECEIVE:2"] = 0, 				-- Indicates whether the COM2 Speaker is on or off. Possible values are 1 or 0.
		["COM TRANSMIT:1"] = 0,				-- Indicates whether COM1 is currently the active radio (theone that will transmit if the pilot presses the PTT button). Possible values are 1 or 0.
		["COM TRANSMIT:2"] = 0,				-- Indicates whether COM2 is currently the active radio (theone that will transmit if the pilot presses the PTT button). Possible values are 1 or 0.
		["ENGINE TYPE"] = 0,				-- Engine type, as an integer. 0 = Piston, 1 = Jet, 2 = None, 3 = Helo(Bell) turbine, 4 = Unsupported, 5 = Turboprop
		["INDICATED ALTITUDE"] = 0,			-- The indicated altitude, in feet
		["MAGNETIC COMPASS"] = 0,			-- The indicated heading, in degrees
		["MAGVAR"] = 0,						-- The magnetic variation at the current position of the aircraft. This will be added to the current heading to get a true heading, thus negative numbers may be used where appropriate. Example value:  -12
		["PLANE ALT ABOVE GROUND MINUS CG"] = 0,   -- The altitude of the plane, above the surface beneath it, measured in feet. If the aircraft is on the ground, this should be 0.
		["PLANE_ALTITUDE"] = 0,				-- The altitude of the plane, above sea level, measured in feet.
		["PLANE BANK DEGREES"] = 0,			-- Current turn angle of the airplane as a positive or negative number. Example: -15 (15 degree turn to the left)
		["PLANE HEADING DEGREES TRUE"] = 0, 	-- True heading of the airplane, after accounting for magnetic variation
		["PLANE LATITUDE"] = 0.0,			-- Current latitude of the airplane, as a decimal.
		["PLANE LONGITUDE"] = 0.0,			-- Current longitude of the airplane, as a decimal.
		["PLANE PITCH DEGREES"] = 0,		-- Current pitch angle of the airplane, in degrees, as a positive or number number. Example:  -15 indicates a 15-degree downward pitch.
		["SEA LEVEL PRESSURE"] = 0,			-- Current barometric pressure, measured in inHG. Example:  2991
		["SIM ON GROUND"] = 0,				-- Indicates whether or not the aircraft is currently on the ground. Possible values are 1 or 0.
		["TOTAL WEIGHT"] = 0, 				-- Total weight (in pounds) of the aircraft and all onboard fuel, passengers, and cargo.
		["TRANSPONDER CODE:1"] = 0,			-- The currently indicated 4-digit transponder code.  (Example: 2543)
		["VERTICAL SPEED"] = 0, 			-- Current vertical speed in feet per minute, expressed as a positive or negative number.
		["WHEEL RPM:0"] = 0,				-- Current speed (in revolutions per minute) of any other wheel.  (This can be the same as WHEEL RPM:0 if you want).
		
		-- OPTIONAL (this should be nil to avoid being written)
		["AMBIENT WIND DIRECTION"] = nil, -- 0,			-- Ambient Wind Direction, in degrees true (at the current position of the aircraft)
		["AMBIENT WIND VELOCITY"] = nil, -- 0, 			-- Ambient Wind Velocity, in knots (at the current position of the aircraft)
		["CIRCUIT COM ON:1"] = nil, -- 0,				-- If the pilot has checked the box for "Aircraft model controls radio power", then this determines whether the circuit-breaker for COM1 is active.  Possible values are 1 or 0. If your simulator does not support this, set this to 1, always.
		["CIRCUIT COM ON:2"] = nil, -- 0,				-- If the pilot has checked the box for "Aircraft model controls radio power", then this determines whether the circuit-breaker for COM2 is active.  Possible values are 1 or 0. If your simulator does not support this, set this to 1, always.
		["ELECTRICAL MASTER BATTERY:0"] = nil, -- 0,	-- If the pilot has checked the box for "Aircraft model controls radio power", then this determines whether the airplane electrical master switch is on or off. Possible values are 1 or 0.
		["LOCAL TIME"] = nil, -- 0.0,					-- The current time in the sim, measured in seconds since midnight. (Example: 3600 = 2am)
		["PLANE TOUCHDOWN LATITUDE"] = nil, -- 0.0, 	-- The exact latitude where the plane last touched down. This is optional, but used to help determine which runway the airplane most recently landed on.
		["PLANE TOUCHDOWN LONGITUDE"] = nil, -- 0.0,	-- The exact longitude where the plane last touched down. This is optional, but used to help determine which runway the airplane most recently landed on.
		["PLANE TOUCHDOWN NORMAL VELOCITY"] = nil, -- 0.0,	-- The "feet per minute" descent rate that was observed at the moment of touchdown. This is optional, but used by various AI personas to judges the smoothness of the most recent landing.
		["TRANSPONDER IDENT"] = nil, -- 0,				-- Indicates whether the transponder is currently in "IDENT" mode. Possible values are 1 or 0.
		["TRANSPONDER STATE:1"] = nil, -- 0, 			-- Current status of the primary transponder.  0 = Off, 1 = Standby, 2 = Test, 3 = On, 4 = Alt, 5 = Ground
		["TYPICAL DESCENT RATE"] = nil, -- 0,			-- The typical descent rate of the aircraft being flown. This is used for TOD calculations. This field is optional, and if left blank, a value of 1000fpm will be assumed.
		["ZULU TIME"] = nil, -- 0.0   					-- The current time in the sim, measured in seconds since midnight. (Example: 3600 = 2am)
	},
	output = {
		["AUDIO_PANEL_VOLUME_SET"] = 0,     -- New value for the Intercom volume, expressed as a percentage from 1 to 100
		["COM1_VOLUME_SET"] = 0,			-- New value for the COM1 Radio volume, expressed as a percentage from 1 to 100
		["COM2_RADIO_SET_HZ"] = 0, 			-- New value for the COM2 Primary Frequency, measured in Hz. (Example: 123455000 is 123.455mhz)
		["COM2_RADIO_SWAP"] = 0,			-- If set to 1, the airplane should swap the COM2 standby/active frequencies
		["COM2_STBY_RADIO_SET_HZ"] = 0,		-- New value for the COM2 Standby Frequency, measured in Hz. (Example: 123455000 is 123.455mhz)
		["COM2_VOLUME_SET"] = 0,			-- New value for the COM2 Radio volume, expressed as a percentage from 1 to 100
		["COM_RADIO_SET_HZ"] = 0,			-- New value for the COM1 Primary Frequency, measured in Hz. (Example: 123455000 is 123.455mhz)
		["COM_RADIO_SWAP"] = 0,				-- If set to 1, the airplane should swap the COM1 standby/active frequencies
		["COM_STBY_RADIO_SET_HZ"] = 0,		-- New value for the COM1 Standby Frequency, measured in Hz. (Example: 123455000 is 123.455mhz)
		["XPNDR_SET"] = 0,					-- New value for the transponder code.
	},
	metadata = {
		name = "DCS World",    			-- (STRING) the plain-text name of your simulator
		version = "2.9",				-- (STRING) the version of your simulator
		exe = "DCS.exe",				-- (STRING) This is the windows file executable name of the simulator. This is used by the SayIntentions.AI to determine whether or not the sim is running.  If the sim is running, it tells the app to read the input file (and write the output file) on a regular basis.
		
		simapi_version = "1.0",			-- (STRING) the version of SI SimAPI being used
		
		adapter_version = "0.9.5"		-- (STRING) the version of this dcs-si-exporter adapter
	}
}


simapi.input_file = siexporter.sayintentions_path .. "simAPI_input.json"
simapi.output_file = siexporter.sayintentions_path .. "simAPI_output.jsonl"

function simapi:write_si_input()
	--siexporter:log("writing SI input")
	local input_format = {
		sim = {
			variables = self.input,
			exe = self.metadata.exe, 
			simapi_version = self.metadata.simapi_version, 
			name = self.metadata.name,
			version = self.metadata.version,
			adapter_version = self.metadata.adapter_version
		} 
	}
    local file = io.open(self.input_file, "w")
    if file then
        file:write(dkjson.encode(input_format))
        file:close()
    else
        siexporter:log("Failed to open " .. self.input_file .. " for writing")
    end
end


function simapi:read_si_output()
	-- siexporter:log("reading SI output")
    local file, err = io.open(self.output_file, "r")
    if not file then
        siexporter:log("Failed to open file: " .. err)
    end

    -- Step 1: nil the outputs before reading so we know what was present
    for k in pairs(self.output) do self.output[k] = nil end

    -- Step 2: Parse the file and set keys to values
    for line in file:lines() do
        if line and line ~= "" then
            local obj, pos, decode_err = dkjson.decode(line)
            if obj and obj.value then
                -- Use the "setvar" field as the key.
                self.output[obj.setvar] = obj.value
            else
                siexporter:log("JSON decode error: " .. decode_err .. " at position: " .. pos)
            end
        end
    end
    file:close()

	-- Step 3: Truncate the file (clears it)
	-- the contract of the output file is that once the values are read they
	-- are expected to be cleared from the file
    local clear_file, cerr = io.open(self.output_file, "w")
    if not clear_file then
        siexporter:log("Failed to clear file: " .. tostring(cerr))
    end
    clear_file:close()
end


return simapi