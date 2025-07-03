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


-- This module abstracts the Aircraft object, loads defaults for all
-- aircraft and then applies overrides for whatever the current aircraft is.

-- REFERENCE for units: https://wiki.hoggitworld.com/view/DCS_Export_Script

Aircraft = {}

function Aircraft:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- -- support 8.333kHz channel spacing
function Aircraft:roundTo833(freq)
    local spacing = 25e3 / 3  -- equals 8333.333...
    return math.floor(freq / spacing + 0.5) * spacing
end

function Aircraft:indicated_airspeed_knots()
	local K = 1.94384    -- (1 nm / 1852 m) * (3600 s / 1 hr) = 1.94384 nm-s / m-hr
	return math.floor(LoGetIndicatedAirSpeed() * K) -- m/s * (1.94384 nm-s / m-hr) = knots (nm/hr)
end

function Aircraft:true_airspeed_knots()
	local K = 1.94384    -- (1 nm / 1852 m) * (3600 s / 1 hr) = 1.94384 nm-s / m-hr
	return math.floor(LoGetTrueAirSpeed() * K) -- m/s to knots
end

-- (INT) Engine type, as an integer. 
-- 0 = Piston, 1 = Jet, 2 = None, 3 = Helo(Bell) turbine, 4 = Unsupported, 5 = Turboprop
function Aircraft:get_engine_type()
	-- default jet for now
	return 1 
end

function Aircraft:indicated_altitude()
	local K = 3.28084   -- ft / 1 m
	return math.floor(LoGetSelfData().LatLongAlt.Alt * K)  -- meters to feet
end

function Aircraft:magnetic_heading()
	return math.deg(LoGetMagneticYaw())
end

function Aircraft:position()
	return {
		lat = LoGetSelfData().LatLongAlt.Lat,
		long = LoGetSelfData().LatLongAlt.Long
	}
end

function Aircraft:altitude_msl()
	local K = 3.28084   -- ft / 1 m
	return math.floor(LoGetAltitudeAboveSeaLevel() * K)  -- meters to feet
end

-- bank in degrees
function Aircraft:bank()
	local pitch, bank, yaw = LoGetADIPitchBankYaw()
	return math.deg(bank)
end

function Aircraft:true_heading()
	 return math.deg(LoGetSelfData().Heading)  -- rad to deg
end

function Aircraft:pitch()
	local pitch, bank, yaw = LoGetADIPitchBankYaw()
	return math.deg(bank)
end

function Aircraft:sea_level_pressure()
	local K = 0.03937  -- 1 in / 25.4 mm  Hg
	return math.floor(LoGetBasicAtmospherePressure() * K)   -- mm hg
end

function Aircraft:vertical_speed()
	local K = 196.8504     -- m/s * 60 s / 1 min * 3.28084 ft / 1 m  = ft/min
	return math.floor(LoGetVerticalVelocity() * K)  -- meters/sec to feet/min 
end

function Aircraft:wind_degress_true()
	local wind = LoGetVectorWindVelocity()
	local direction_rad = math.atan2(wind.x, wind.z)
	local direction_deg = (math.deg(direction_rad) + 360) % 360
	return direction_deg
end

function Aircraft:wind_knots()
	local wind = LoGetVectorWindVelocity()
	local speed_mps = math.sqrt(wind.x^2 + wind.z^2)
	local speed_knots = speed_mps * 1.94384
	return speed_knots
end



return Aircraft


-- F-16C_50
-- FA-18C_hornet
-- F-5E-3




-- function aircraft_api.get_vhf_frequency(aircraft_type)
-- 	local frequency  -- in Hz
-- 	local dev -- device for VHF

-- 	if aircraft_type == "F-16C_50" then
-- 		dev = GetDevice(38) -- COMM 2 (VHF) device ID
-- 		frequency = roundTo833(dev:get_frequency())
-- 	elseif aircraft_type == "FA-18C_hornet" then 
-- 		dev = GetDevice(38) -- COMM 2 (VHF) device ID
-- 		frequency = roundTo833(dev:get_frequency())
-- 	elseif aircraft_type == "F-5E-3" then
-- 		dev = GetDevice(23) -- COMM 2 (VHF) device ID
-- 		frequency = roundTo833(dev:get_frequency())
-- 	end

-- 	return frequency
-- end

-- function aircraft_api.set_vhf_frequency(aircraft_type, frequency)
-- 	local dev -- device for VHF

-- 	if aircraft_type == "F-16C_50" then
-- 		dev = GetDevice(38) -- COMM 2 (VHF) device ID
-- 		dev:set_frequency( frequency )
-- 	elseif aircraft_type == "FA-18C_hornet" then 
-- 		dev = GetDevice(38) -- COMM 2 (VHF) device ID
-- 		dev:set_frequency( frequency )
-- 	elseif aircraft_type == "F-5E-3" then
-- 		dev = GetDevice(23) -- COMM 2 (VHF) device ID
-- 		dev:set_frequency( frequency )
-- 	end
-- end

-- function aircraft_api.get_mode3_code(aircraft_type)
-- 	local xpdr

-- 	if aircraft_type == "F-16C_50" then
-- 		-- mod 3 transponder ID for F-16C
-- 	    local digit1 = math.floor(GetDevice(0):get_argument_value(546) * 10 + 0.5)
-- 	    local digit2 = math.floor(GetDevice(0):get_argument_value(548) * 10 + 0.5)
-- 	    local digit3 = math.floor(GetDevice(0):get_argument_value(550) * 10 + 0.5)
-- 	    local digit4 = math.floor(GetDevice(0):get_argument_value(552) * 10 + 0.5)

-- 	    xpdr = digit1 * 1000 + digit2 * 100 + digit3 * 10 + digit4 * 1

-- 	elseif aircraft_type == "F-5E-3" then

-- 	    local digit1 = math.floor(GetDevice(0):get_argument_value(211) * 10 + 0.5)
-- 	    local digit2 = math.floor(GetDevice(0):get_argument_value(212) * 10 + 0.5)
-- 	    local digit3 = math.floor(GetDevice(0):get_argument_value(213) * 10 + 0.5)
-- 	    local digit4 = math.floor(GetDevice(0):get_argument_value(214) * 10 + 0.5)

-- 	    xpdr = digit1 * 1000 + digit2 * 100 + digit3 * 10 + digit4 * 1

-- 	elseif aircraft_type == "FA-18C_hornet" then 

-- 		-- heh. this is complete madness in terms of an api, but here we are.
-- 		-- kudos to SRS and DCS-BIOS for figuring this out!
-- 		-- I suspect that ED has another field much easier to access somewhere in their 
-- 		-- internal API, but it might not even be exposed to lua.
-- 		local ufc_raw = list_indication(6)
-- 		local _ufc = {}

-- 		-- stream parsing our way to glory!
-- 		local ufc_match = ufc_raw:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
-- 	    while true do
-- 	        local Key, Value = ufc_match()
-- 	        if not Key then
-- 	            break
-- 	        end
-- 	        _ufc[Key] = Value
-- 	    end

-- 	    -- hacking the virtual display output to grab temporary state reminds me of 
-- 	    -- hacking redstone computers in minecraft...
-- 		if _ufc then
-- 			local scratchpad = _ufc.UFC_ScratchPadString1Display .. _ufc.UFC_ScratchPadString2Display
			
-- 			if scratchpad == "XP" then 
-- 				scratchpad_num = _ufc.UFC_ScratchPadNumberDisplay
-- 				local mode, code = string.match(scratchpad_num, "([23])%-([0-7]+)")
				
-- 				if code then 
-- 					xpdr = math.floor(tonumber(code)) 
-- 				end
-- 			end
-- 		end
-- 	end

-- 	return xpdr
-- end

-- function aircraft_api.set_mode3_code(aircraft_type, code)
-- 	-- code comes in from siout as a string
-- 	local code_int = math.floor(tonumber(code)) 
-- 	-- TODO
-- end

-- function aircraft_api.get_motw(aircraft_type)
-- 	if aircraft_type == "F-16C_50" then
-- 		return 42300
-- 	elseif aircraft_type == "FA-18C_hornet" then 
-- 		return 51900
-- 	elseif aircraft_type == "F-5E-3" then
-- 		return 24675
-- 	else
-- 		return 10000 -- unknown aircraft
-- 	end
-- end

-- -- (INT) Engine type, as an integer. 
-- -- 0 = Piston, 1 = Jet, 2 = None, 3 = Helo(Bell) turbine, 4 = Unsupported, 5 = Turboprop
-- function aircraft_api.get_engine_type(aircraft_type)
-- 	if aircraft_type == "F-16C_50" then
-- 		return 1
-- 	elseif aircraft_type == "FA-18C_hornet" then 
-- 		return 1
-- 	elseif aircraft_type == "F-5E-3" then
-- 		return 1
-- 	else
-- 		return 1 -- unknown aircraft (jet for now)
-- 	end
-- end

