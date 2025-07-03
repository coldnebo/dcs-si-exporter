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

local FA18 = Aircraft:new()

function FA18:get_vhf_frequency()
    local dev = GetDevice(38) -- COMM 2 (VHF) device ID
    -- freq in Hz
    local frequency = self:roundTo833(dev:get_frequency())
    
    return frequency
end

-- freq in Hz
function FA18:set_vhf_frequency(frequency)
    local dev = GetDevice(38) -- COMM 2 (VHF) device ID
    dev:set_frequency( frequency )
end

function FA18:get_mode3_code()
    -- heh. this is complete madness in terms of an api, but here we are.
    -- kudos to SRS and DCS-BIOS for figuring this out!
    -- I suspect that ED has another field much easier to access somewhere in their 
    -- internal API, but it might not even be exposed to lua.
    local ufc_raw = list_indication(6)
    local _ufc = {}
    local xpdr

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

    return xpdr
end


return FA18