local r = reaper

function log(str, clear)
    if clear then r.ClearConsole() end
    r.ShowConsoleMsg('\n' .. tostring(str))
end

