reaper.ClearConsole()
t1 = os.clock()

for i=1, reaper.GetNumTracks() do
    track = reaper.GetTrack(0, i)
end

t2 = os.clock()

reaper.ShowConsoleMsg(string.format('\nthe time difference is %.6f', t2-t1))
