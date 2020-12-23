local path = ""
function reaperDoFile(file) local info = debug.getinfo(1,'S'); path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(path .. file); end
reaperDoFile('../libss/cf.lua')

local retval, retvals_csv = reaper.GetUserInputs("Generate Script", 1, "Name:", "Name")
if not retval then return end

local file = io.open(path .. retvals_csv .. '.lua', 'w')
io.output()

file:write('reaper.ShowConsoleMsg("hi")')
file:close()
local t = 1
for c = 1, 120 do t = t + 1 end

local l = reaper.AddRemoveReaScript(true,  32060, path .. retvals_csv .. ".lua", true)
reaper.ShowConsoleMsg(l)



