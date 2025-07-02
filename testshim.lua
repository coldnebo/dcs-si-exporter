local lfs = require("lfs")
function lfs.writedir()
  return [[C:\Users\lkyra\Saved Games\DCS.openbeta\]]  -- or use "/" if you prefer
end
local ok, err = pcall(function()
    dofile(lfs.writedir() .. [[Mods\Services\SayIntentionsExport\SayIntentionsExport.lua]])
end)

if not ok then
    print("Error: " .. tostring(err))
end