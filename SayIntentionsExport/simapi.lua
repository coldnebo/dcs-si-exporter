local simapi = {}


function simapi.default_input()
	local data = {}

	data["sim"] = {}
	data["sim"]["variables"] = {}

	local sim_data = data["sim"]
    local var_data = data["sim"]["variables"]


	-- SayIntentions.AI SimAPI v1.0 INPUT variables
	-- from https://portal.sayintentions.ai/simapi/v1/input_variables.txt
	-- retrieved 2025-04-09
	
	-- ===== REQUIRED VARIABLES =====

	-- REQUIRED:INSTRUMENTS

	var_data["AIRSPEED INDICATED"] = 0 				-- (INT) Indicated Airspeed in Knots
	
	var_data["COM ACTIVE FREQUENCY:1"] = 100.00    	-- (FLOAT) The current value of the COM1 Active Frequency, in MHz.  Example value:  118.32
	var_data["COM ACTIVE FREQUENCY:2"] = 100.00 	-- (FLOAT) The current value of the COM2 Active Frequency, in MHz.  Example value:  132.14
	
	var_data["COM RECEIVE:1"] = 0 					-- (INT) Indicates whether the COM1 Speaker is on or off. Possible values are 1 or 0.
	var_data["COM RECEIVE:2"] = 0    				-- (INT) Indicates whether the COM2 Speaker is on or off. Possible values are 1 or 0.

	var_data["COM TRANSMIT:1"] = 0 					-- (INT) Indicates whether COM1 is currently the active radio (theone that will transmit if the pilot presses the PTT button). Possible values are 1 or 0.
	var_data["COM TRANSMIT:2"] = 0   				-- (INT) Indicates whether COM2 is currently the active radio (theone that will transmit if the pilot presses the PTT button). Possible values are 1 or 0.

	var_data["INDICATED ALTITUDE"] = 0    			-- (INT) The indicated altitude, in feet
	var_data["MAGNETIC COMPASS"] = 0 				-- (INT) The indicated heading, in degrees
	var_data["TRANSPONDER CODE:1"] = 0   			-- (INT) The currently indicated 4-digit transponder code.  (Example: 2543)

	
	-- REQUIRED:TELEMETRY

	var_data["AIRSPEED TRUE"] = 0  					-- (INT) True (Ground) Airspeed in Knots
	var_data["MAGVAR"] = 0  						-- (INT) The magnetic variation at the current position of the aircraft. This will be added to the current heading to get a true heading, thus negative numbers may be used where appropriate. Example value:  -12
	
	var_data["PLANE ALT ABOVE GROUND MINUS CG"] = 0 -- (INT) The altitude of the plane, above the surface beneath it, measured in feet. If the aircraft is on the ground, this should be 0.
	var_data["PLANE ALTITUDE"] = 0  				-- (INT) The altitude of the plane, above sea level, measured in feet.
	var_data["PLANE BANK DEGREES"] = 0 				-- (INT) Current turn angle of the airplane as a positive or negative number. Example: -15 (15 degree turn to the left)
	var_data["PLANE HEADING DEGREES TRUE"] = 0  	-- (INT) True heading of the airplane, after accounting for magnetic variation
	var_data["PLANE LATITUDE"] = 0.0 				-- (FLOAT) Current latitude of the airplane, as a decimal.
	var_data["PLANE LONGITUDE"] = 0.0 				-- (FLOAT) Current longitude of the airplane, as a decimal.
	var_data["PLANE PITCH DEGREES"] = 0 			-- (INT) Current pitch angle of the airplane, in degrees, as a positive or number number. Example:  -15 indicates a 15-degree downward pitch.
	
	var_data["SEA LEVEL PRESSURE"] = 0  			-- (INT) Current barometric pressure, measured in inHG. Example:  2991
	var_data["SIM ON GROUND"] = 0  					-- (INT) Indicates whether or not the aircraft is currently on the ground. Possible values are 1 or 0.

	var_data["TOTAL WEIGHT"] = 0 					-- (INT) Total weight (in pounds) of the aircraft and all onboard fuel, passengers, and cargo.
	var_data["VERTICAL SPEED"] = 0  				-- (INT) Current vertical speed in feet per minute, expressed as a positive or negative number.

	var_data["WHEEL RPM:1"] = 0  					-- (INT) Current speed (in revolutions per minute) of any other wheel.  (This can be the same as WHEEL RPM:0 if you want).

	-- REQUIRED:AIRCRAFT DETAILS

	var_data["ENGINE TYPE"] = 4  					-- (INT) Engine type, as an integer. 0 = Piston, 1 = Jet, 2 = None, 3 = Helo(Bell) turbine, 4 = Unsupported, 5 = Turboprop



	-- ===== OPTIONAL VARIABLES =====

	-- OPTIONAL:INSTRUMENTS

	var_data["CIRCUIT COM ON:1"] = 1  				-- (INT) If the pilot has checked the box for "Aircraft model controls radio power", then this determines whether the circuit-breaker for COM1 is active.  Possible values are 1 or 0. If your simulator does not support this, set this to 1, always.
	var_data["CIRCUIT COM ON:2"] = 1 				-- (INT) If the pilot has checked the box for "Aircraft model controls radio power", then this determines whether the circuit-breaker for COM2 is active.  Possible values are 1 or 0. If your simulator does not support this, set this to 1, always.

	var_data["ELECTRICAL MASTER BATTERY:0"] = 1  	-- (INT) If the pilot has checked the box for "Aircraft model controls radio power", then this determines whether the airplane electrical master switch is on or off. Possible values are 1 or 0.

	var_data["TRANSPONDER IDENT"] = 0 				-- (INT) Indicates whether the transponder is currently in "IDENT" mode. Possible values are 1 or 0.
	var_data["TRANSPONDER STATE:1"] = 4 			-- (INT) Current status of the primary transponder.  0 = Off, 1 = Standby, 2 = Test, 3 = On, 4 = Alt, 5 = Ground

	-- OPTIONAL:TELEMETRY

	var_data["AMBIENT WIND DIRECTION"] = 0 			-- (INT) Ambient Wind Direction, in degrees true (at the current position of the aircraft)
	var_data["AMBIENT WIND VELOCITY"] = 0  			-- (INT) Ambient Wind Velocity, in knots (at the current position of the aircraft)

	var_data["PLANE TOUCHDOWN LATITUDE"] = 0.0 		-- (FLOAT) The exact latitude where the plane last touched down. This is optional, but used to help determine which runway the airplane most recently landed on.
	var_data["PLANE TOUCHDOWN LONGITUDE"] = 0.0 	-- (FLOAT) The exact longitude where the plane last touched down. This is optional, but used to help determine which runway the airplane most recently landed on.
	var_data["PLANE TOUCHDOWN NORMAL VELOCITY"] = 0.0  -- (FLOAT) The "feet per minute" descent rate that was observed at the moment of touchdown. This is optional, but used by various AI personas to judges the smoothness of the most recent landing.

	var_data["LOCAL TIME"] = 0.0  					-- (FLOAT) The current time in the sim, measured in seconds since midnight. (Example: 3600 = 2am)
	var_data["ZULU TIME"] = 0.0 					-- (FLOAT) The current time in the sim, measured in seconds since midnight. (Example: 3600 = 2am)

	-- OPTIONAL:AIRCRAFT DETAILS

	var_data["TYPICAL DESCENT RATE"] = 2000 		-- (INT) The typical descent rate of the aircraft being flown. This is used for TOD calculations. This field is optional, and if left blank, a value of 1000fpm will be assumed.


	-- SIM Data
	-- from https://sayintentionsai.freshdesk.com/support/solutions/articles/154000221017-simapi-developer-howto-integrating-sayintentions-ai-with-any-flight-simulator
	-- retrieved 2025-04-09

    sim_data["name"]            = "DCS World"       -- (STRING) the plain-text name of your simulator
    sim_data["version"]         = "2.9"             -- (STRING) the version of your simulator
    sim_data["adapter_version"] = "0.1"     		-- (STRING) the version of the dcs-si-exporter adapter
    sim_data["simapi_version"]  = "1.0"				-- (STRING) the version of SI SimAPI being used
    sim_data["exe"]             = "DCS.exe"			-- (STRING) This is the windows file executable name of the simulator. This is used by the SayIntentions.AI to determine whether or not the sim is running.  If the sim is running, it tells the app to read the input file (and write the output file) on a regular basis.

	return data, var_data, sim_data
end


function simapi.fetch_output(json, output_file)
    local data = {}

    local file, err = io.open(output_file, "r")
    if not file then
        error("Failed to open file: " .. err)
    end

    for line in file:lines() do
        if line and line ~= "" then
            local obj, pos, decode_err = json.decode(line)
            if obj then
                -- Use the "setvar" field as the key.
                data[obj.setvar] = obj.value
            else
                error("JSON decode error: " .. decode_err .. " at position: " .. pos)
            end
        end
    end
    file:close()

	-- Step 2: Truncate the file (clears it)
    local clear_file, cerr = io.open(output_file, "w")
    if not clear_file then
        error("Failed to clear file: " .. tostring(cerr))
    end
    clear_file:close()

    return data
end



return simapi