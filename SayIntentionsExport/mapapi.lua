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



local mapapi = {}


function mapapi.getMagVarByLocation(lat, lon)

    -- Define known DCS map boundaries and typical magvars
    local mapZones = {
        {
            name = "Caucasus",
            latMin = 41.0, latMax = 47.0,
            lonMin = 37.0, lonMax = 47.0,
            magvar = -8
        },
        {
            name = "Persian Gulf",
            latMin = 23.0, latMax = 28.5,
            lonMin = 53.0, lonMax = 58.0,
            magvar = -4
        },
        {
            name = "Nevada",
            latMin = 35.0, latMax = 38.5,
            lonMin = -117.5, lonMax = -113.0,
            magvar = -11.5
        },
        {
            name = "Marianas",
            latMin = 13.0, latMax = 21.0,
            lonMin = 142.0, lonMax = 146.0,
            magvar = -3
        }
    }

    for _, zone in ipairs(mapZones) do
        if lat >= zone.latMin and lat <= zone.latMax and
           lon >= zone.lonMin and lon <= zone.lonMax then
            return zone.magvar
        end
    end

    -- Default fallback value
    return 0.0
end


return mapapi
