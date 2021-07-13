cmd = 'y'
function reaperDoFile(file)
    local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); 
end
reaperDoFile('../multikey.lua')
main()
