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
	o.vhf_frequency = 122800000
	o.xpdr = 1200
	setmetatable(o, self)
	self.__index = self
	return o
end


-- aircraft specific interface, abstract methods
-- implement these in specific aircraft to provide functionality for the exporter.

function Aircraft:get_vhf_frequency()
    --siexporter:log("abstract method 'get_vhf_frequency' not implemented.")
    return self.vhf_frequency
end

-- freq in Hz
function Aircraft:set_vhf_frequency(frequency)
    --siexporter:log("abstract method 'set_vhf_frequency' not implemented.")
    self.vhf_frequency = frequency
end

function Aircraft:get_mode3_code()
	--siexporter:log("abstract method 'get_mode3_code' not implemented.")
	return self.xpdr
end

function Aircraft:set_mode3_code(xpdr)
	--siexporter:log("abstract method 'set_mode3_code' not implemented.")
	self.xpdr = xpdr
end

-- Current status of the primary transponder.  0 = Off, 1 = Standby, 2 = Test, 3 = On, 4 = Alt, 5 = Ground
-- default implementation for all aircraft is to hardcode ALT so that mode c is reported.
function Aircraft:transponder_state()
	return 4 -- Alt
end

-- default for all aircraft, overide if desired
function Aircraft:typical_descent_rate()
	return 2000
end

-- default weight for all aircraft unless specified in a subclass (ballpark)
function Aircraft:total_weight()
	return 10000
end

-- default cg_height in feet. varies by plane. 10 feet is large, but should 
-- force the sim on ground. sorry low fliers! lol
function Aircraft:cg_height()
	return 10
end


-- internal helper
-- -- support 8.333kHz channel spacing
function Aircraft:roundTo833(freq)
    local spacing = 25e3 / 3  -- equals 8333.333...
    return math.floor(freq / spacing + 0.5) * spacing
end

-- generic implementations
-- these are functions that all aircraft share and can be implemented at 
-- the base class level.
function Aircraft:indicated_airspeed_knots()
	local K = 1.94384    -- (1 nm / 1852 m) * (3600 s / 1 hr) = 1.94384 nm-s / m-hr
	return math.floor(LoGetIndicatedAirSpeed() * K) -- m/s * (1.94384 nm-s / m-hr) = knots (nm/hr)
end

function Aircraft:true_airspeed_knots()
	local K = 1.94384    -- (1 nm / 1852 m) * (3600 s / 1 hr) = 1.94384 nm-s / m-hr
	return math.floor(LoGetTrueAirSpeed() * K) -- m/s to knots
end

-- Assuming a typical military main gear wheel with diameter ≈ 0.8 m (≈ 31.5 inches), the circumference is about:
-- circumference = π * diameter ≈ 3.14 * 0.8 ≈ 2.51 meters
function Aircraft:wheel_rpm()
	local speed_mps = LoGetTrueAirSpeed() -- m/s
	-- RPM = (speed / circumference) * 60
	local wheel_rpm = (speed_mps / 2.51) * 60
	return math.floor(wheel_rpm)
end

-- (INT) Engine type, as an integer. 
-- 0 = Piston, 1 = Jet, 2 = None, 3 = Helo(Bell) turbine, 4 = Unsupported, 5 = Turboprop
function Aircraft:get_engine_type()
	-- default jet for now
	return 1 
end

-- same as, see: altitude_msl()
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

-- both LoGetAltitudeAboveSeaLevel() and LoGetSelfData().LatLongAlt.Alt are returning 
-- what appear to be geometric altitudes based on world coords.
-- HENCE: no matter what the mission QNH is set to, this will always be field elevation!!!
--
-- irl, msl would always be baro corrected altitude and have a baro context, but you might
-- set it to field elevation based on the local ATIS. baro setting is not always the same as SLP in the metar
-- for this reason -- and neither of these are the same as GPS altitude, which is almost never used.
-- still, the end game for SI is getting essentially the geometric altitude by using all these other facts
-- so if we already have the geometric altitude, we don't need the baro altitude really.
-- DCS apparently simulates the baro setting internally for instruments but doesn't expose this.
function Aircraft:altitude_msl()
	--siexporter:log("LoGetAltitudeAboveSeaLevel() : " .. tostring(LoGetAltitudeAboveSeaLevel() or "nil"))
	local K = 3.28084   -- ft / 1 m
	return math.floor(LoGetAltitudeAboveSeaLevel() * K)  -- meters to feet
end

-- this seems to be an accurate measure above the ground, think of it like a radar altimeter.
-- it is offset by the aircraft cg, so when on the ground, it is still a few feet above the ground
-- depending on the aircraft.  see aircraft:cg_height() to compensate/calculate for SIM ON GROUND.
function Aircraft:altitude_agl()
	local K = 3.28084   -- ft / 1 m
	return math.floor(LoGetAltitudeAboveGroundLevel() * K)  -- meters to feet
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
	return math.deg(pitch)
end

-- LoGetBasicAtmospherePressure() seems to be returning nil
function Aircraft:sea_level_pressure()
	-- log all the things we might use to get this and see what the values are?
	-- siexporter:log("LoGetBasicAtmospherePressure() : " .. tostring(LoGetBasicAtmospherePressure() or "nil"))
	-- siexporter:log("LoGetAltitudeAboveSeaLevel() : " .. tostring(LoGetAltitudeAboveSeaLevel() or "nil"))
	-- siexporter:log("LoGetSelfData().LatLongAlt.Alt : " .. tostring(LoGetSelfData().LatLongAlt.Alt) or "nil")
	-- results:
	-- so this isn't defined in an exporter context. (was set to 30.00 on the mission)
	-- dcs-si-exporter: [LoGetBasicAtmospherePressure() : nil] reached at Fri Jul  4 12:27:31 2025
	-- and unfortunately, the self data and msl altitudes are the same... so we can't calc baro from that.
	-- dcs-si-exporter: [LoGetAltitudeAboveSeaLevel() : 568.24041748047] reached at Fri Jul  4 12:27:31 2025
	-- dcs-si-exporter: [LoGetSelfData().LatLongAlt.Alt : 568.24040354895] reached at Fri Jul  4 12:27:31 2025

	local K = 0.03937  -- 1 in / 25.4 mm  Hg
	pressure = LoGetBasicAtmospherePressure() or 760.73001  -- standard pressure if nil
	return math.floor(pressure * K * 100)   -- mm hg -> in hg * 100 (e.g. 2991)
end

function Aircraft:vertical_speed()
	local K = 196.8504     -- m/s * 60 s / 1 min * 3.28084 ft / 1 m  = ft/min
	return math.floor(LoGetVerticalVelocity() * K)  -- meters/sec to feet/min 
end

function Aircraft:wind_degrees_true()
	local wind = LoGetVectorWindVelocity()
	-- siexporter:log("wind velocity vec: " .. tostring(wind.x) .. ", " .. tostring(wind.y) .. ", " .. tostring(wind.z))
	-- siexporter:log("atan2: " .. tostring(math.atan2(wind.x, wind.z)))
	local direction_deg = (math.deg(math.atan2(wind.x, wind.z))) % 360
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

