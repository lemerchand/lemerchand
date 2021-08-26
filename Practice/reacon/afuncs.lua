local afuncs = {}

function afuncs.quit() Script.quit = true end
function afuncs.showTrackview(win) win.context = 'TRACKVIEW' end
function afuncs.showClog(win) win.context = 'CLOG' end

return afuncs
