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


-- optional realweather integration 
-- the only thing really needed is the baro pressure line

local M = {}

-- Path to the log file (you can change this if needed)
local log_path = siexporter.realweather_path .. "realweather.log"

-- Function to extract the last pressure value (inHg * 100)
function M.get_pressure()
    local last_pressure_line = nil

    local file = io.open(log_path, "r")
    if not file then
        siexporter:log("realweatherapi: Failed to open realweather log file (skipping pressure): " .. log_path)
        return nil, "Failed to open realweather log file: " .. log_path
    end

    siexporter:log("realweatherapi: Found realweather log file: " .. log_path)

    for line in file:lines() do
        if line:find("pressure:") then
            last_pressure_line = line
        end
    end

    file:close()

    if not last_pressure_line then
        siexporter:log("realweatherapi: No pressure line found")
        return nil, "No pressure line found"
    end

    local json_str = string.match(last_pressure_line, "{.*}")
    if not json_str then
        siexporter:log("realweatherapi: Malformed pressure line")
        return nil, "Malformed pressure line"
    end

    local inHg = tonumber(string.match(json_str, '"inHg"%s*:%s*([%d%.]+)'))
    if not inHg then
        siexporter:log("realweatherapi: Couldn't parse inHg value")
        return nil, "Couldn't parse inHg value"
    end

    siexporter:log("realweatherapi: found pressure (inHg): " .. inHg)
    
    return math.floor(inHg * 100 + 0.5)
end

return M
