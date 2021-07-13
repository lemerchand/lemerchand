from time import perf_counter

RPR_ClearConsole()
t1 = perf_counter()

for i in range(RPR_GetNumTracks()):
    track = RPR_GetTrack(0, i)

t2 = perf_counter()

RPR_ShowConsoleMsg(f'the time difference be {t2-t1}')
