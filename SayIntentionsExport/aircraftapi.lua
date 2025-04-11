local aircraft_api = {}

-- F-16C_50
-- FA-18C_hornet

local sayintentions_path = os.getenv("LOCALAPPDATA") .. "\\SayIntentionsAI\\"
local simapi_debug_file = sayintentions_path .. "dcs-si-exporter_debug.txt"

local function log_marker(msg)
    local log = io.open(simapi_debug_file, "a")
    log:write("aircraftapi: [" .. msg .. "] reached at " .. os.date() .. "\n")
    log:close()
end


-- support 8.333kHz channel spacing
local function roundTo833(freq)
    local spacing = 25e3 / 3  -- equals 8333.333...
    return math.floor(freq / spacing + 0.5) * spacing
end


function aircraft_api.get_vhf_frequency(aircraft_type)
	local frequency  -- in Hz
	local dev -- device for VHF

	if aircraft_type == "F-16C_50" then
		dev = GetDevice(38) -- COMM 2 (VHF) device ID
		frequency = roundTo833(dev:get_frequency())
	elseif aircraft_type == "FA-18C_hornet" then 
		dev = GetDevice(38) -- COMM 2 (VHF) device ID
		frequency = roundTo833(dev:get_frequency())
	end

	return frequency
end


function aircraft_api.set_vhf_frequency(aircraft_type, frequency)
	local dev -- device for VHF
	if aircraft_type == "F-16C_50" then
		dev = GetDevice(38) -- COMM 2 (VHF) device ID
		dev:set_frequency( frequency )
	elseif aircraft_type == "FA-18C_hornet" then 
		dev = GetDevice(38) -- COMM 2 (VHF) device ID
		dev:set_frequency( frequency )
	end
end

function aircraft_api.get_mode3_code(aircraft_type)
	local xpdr

	if aircraft_type == "F-16C_50" then
		-- mod 3 transponder ID for F-16C
	    local digit1 = math.floor(GetDevice(0):get_argument_value(546) * 10 + 0.5)
	    local digit2 = math.floor(GetDevice(0):get_argument_value(548) * 10 + 0.5)
	    local digit3 = math.floor(GetDevice(0):get_argument_value(550) * 10 + 0.5)
	    local digit4 = math.floor(GetDevice(0):get_argument_value(552) * 10 + 0.5)

	    xpdr = digit1 * 1000 + digit2 * 100 + digit3 * 10 + digit4 * 1

	elseif aircraft_type == "FA-18C_hornet" then 

		local ufc_raw = list_indication(6)
		local _ufc = {}

		local ufc_match = ufc_raw:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
	    while true do
	        local Key, Value = ufc_match()
	        if not Key then
	            break
	        end
	        _ufc[Key] = Value
	    end

		if _ufc then
			local scratchpad = _ufc.UFC_ScratchPadString1Display .. _ufc.UFC_ScratchPadString2Display
			
			if scratchpad == "XP" then 
				scratchpad_num = _ufc.UFC_ScratchPadNumberDisplay
				local mode, code = string.match(scratchpad_num, "([23])%-([0-7]+)")
				
				if code then 
					xpdr = math.floor(tonumber(code)) 
				end
			end
		end
	end

	return xpdr
end

function aircraft_api.set_mode3_code(aircraft_type, code)
	-- code comes in from siout as a string
	local code_int = math.floor(tonumber(code)) 
	-- TODO
end


return aircraft_api