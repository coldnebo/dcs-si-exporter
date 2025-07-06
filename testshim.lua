local lfs = require("lfs")

-- shims
function lfs.writedir()
  return [[C:\Users\lkyra\Saved Games\DCS.openbeta\]]  -- or use "/" if you prefer
end

function LoGetSelfData()
  return {
    Name = "F-16C_50"
  }
end

function GetDevice(n)
  return {
    get_frequency = function()
      return 121500029   -- with some rounding error to make it realistic
    end
  }
end

function LoGetIndicatedAirSpeed()
    return 77.16667  -- return meters/second or whatever test value you want
end



-- ok, load the file like the exporter does.
local ok, err = pcall(function()
    dofile(lfs.writedir() .. [[Mods\Services\SayIntentionsExport\SayIntentionsExport.lua]])
end)

if not ok then
    print("Error: " .. tostring(err))
end