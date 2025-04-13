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


-- Portions of this code adapted from DCS SimpleRadioStandalone (SRS) http://dcssimpleradio.com/
-- Source: https://github.com/ciribob/DCS-SimpleRadioStandalone (GPLv3)
-- Original Author(s): Ciaran Fisher
-- Adapted by: Larry Kyrala for dcs-si-exporter


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

		-- heh. this is complete madness in terms of an api, but here we are.
		-- kudos to SRS and DCS-BIOS for figuring this out!
		-- I suspect that ED has another field much easier to access somewhere in their 
		-- internal API, but it might not even be exposed to lua.
		local ufc_raw = list_indication(6)
		local _ufc = {}

		-- stream parsing our way to glory!
		local ufc_match = ufc_raw:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
	    while true do
	        local Key, Value = ufc_match()
	        if not Key then
	            break
	        end
	        _ufc[Key] = Value
	    end

	    -- hacking the virtual display output to grab temporary state reminds me of 
	    -- hacking redstone computers in minecraft...
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