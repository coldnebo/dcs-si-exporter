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
            latMin = 38.865556, latMax = 48.383333,
            lonMin = 26.785833, lonMax = 49.271111,
            magvar = -7
        },
        {
            name = "Persian Gulf",
            latMin = 21.869722, latMax = 32.9575,
            lonMin = 46.607222, lonMax = 63.991667,
            magvar = -3
        },
        {
            name = "Nevada",
            latMin = 34.346944, latMax = 39.801667,
            lonMin = -119.986944, lonMax = -112.448889,
            magvar = -11.5
        },
        {
            name = "Marianas",
            latMin = 10.739167, latMax = 22.214722,
            lonMin = 136.9675, lonMax = 152.118056,
            magvar = -2
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
