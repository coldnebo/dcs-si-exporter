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


local Aircraft = siexporter:safe_require("aircraft") -- or adjust path if needed

local A10C = Aircraft:new()

function A10C:get_vhf_frequency()
    local dev = GetDevice(55) -- COMM 2 (VHF) device ID
    -- freq in Hz
    local frequency = self:roundTo833(dev:get_frequency())
    
    return frequency
end

-- freq in Hz
function A10C:set_vhf_frequency(frequency)
    local dev = GetDevice(55) -- COMM 2 (VHF) device ID
    dev:set_frequency( frequency )
end

function A10C:get_mode3_code()
    -- _data.iff.mode3 = SR.round(SR.getButtonPosition(211), 0.1) * 10000 + SR.round(SR.getButtonPosition(212), 0.1) * 1000 + SR.round(SR.getButtonPosition(213), 0.1)* 100 + SR.round(SR.getButtonPosition(214), 0.1) * 10

     -- mod 3 transponder ID for F-16C
     local digit1 = math.floor(GetDevice(0):get_argument_value(211) * 10 + 0.5)
     local digit2 = math.floor(GetDevice(0):get_argument_value(212) * 10 + 0.5)
     local digit3 = math.floor(GetDevice(0):get_argument_value(213) * 10 + 0.5)
     local digit4 = math.floor(GetDevice(0):get_argument_value(214) * 10 + 0.5)

     local xpdr = digit1 * 1000 + digit2 * 100 + digit3 * 10 + digit4 * 1

     return xpdr
end

function A10C:transponder_ident()
    local iffIdent = math.floor(GetDevice(0):get_argument_value(207) * 1 + 0.5)
    --siexporter:log("iffIdent: " .. tostring(iffIdent))
    if iffIdent == 1 then
        return 1 
    else 
        return 0
    end 
end

function A10C:total_weight()
    return 51000
end


return A10C