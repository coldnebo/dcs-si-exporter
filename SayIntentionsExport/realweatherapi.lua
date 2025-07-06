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
local log_path = [[D:\games\dcs_apps\realweather_v2.1.1\realweather.log]]

-- Function to extract the last pressure value (inHg * 100)
function M.get_pressure()
    local last_pressure_line = nil

    local file = io.open(log_path, "r")
    if not file then
        return nil, "Failed to open log file: " .. log_path
    end

    for line in file:lines() do
        if line:find("pressure:") then
            last_pressure_line = line
        end
    end

    file:close()

    if not last_pressure_line then
        return nil, "No pressure line found"
    end

    local json_str = string.match(last_pressure_line, "{.*}")
    if not json_str then
        return nil, "Malformed pressure line"
    end

    local inHg = tonumber(string.match(json_str, '"inHg"%s*:%s*([%d%.]+)'))
    if not inHg then
        return nil, "Couldn't parse inHg value"
    end

    return math.floor(inHg * 100 + 0.5)
end

return M
