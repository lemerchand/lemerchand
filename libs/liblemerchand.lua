--   __   _ __   __                         __                __
--  / /  (_) /  / /  ___ __ _  ___ ________/ /  ___ ____  ___/ /
-- / /__/ / _ \/ /__/ -_)  ' \/ -_) __/ __/ _ \/ _ `/ _ \/ _  /
--/____/_/_.__/____/\__/_/_/_/\__/_/  \__/_//_/\_,_/_//_/\_,_/
--
-- An (anything-but) Standard Library for Lua
--
-- Author: Lemerchand
-- I would like to give credit to the following coders for marking
-- quality Open Source material for me to study, and modify:
--
--     * Luca Anzalone - luatable - https://github.com/Luca96/lua-table
--
local std      =   {}
local class    =   require('middleclass')
local format   =   string.format
std.table      =   {}
local r        =   reaper
local last     =   {}

last.func, last.linenum = nil, nil

function std.dbg(str, clear, ...)
    if not Script.debug then return end
    if clear then r.ClearConsole() end
    local arg = {...}
    if not arg[1] then arg[1] = '' end

    local funcname = debug.getinfo(2, 'n').name
    local linenum  = debug.getinfo(2, 'l').currentline
    local source   = debug.getinfo(2, 'S').short_src
    source = string.reverse(source)
    source = string.reverse(source:sub(1, source:find('[\\/%s]')-1))

    local msg = ''

    if (funcname ~= last.func) and (linenum ~= last.linenum) then
	msg = msg ..
	    '\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-' ..
	    '\n-= FUNC: ' .. funcname ..
            '\n-= FILE: ' .. source ..
	    '\n-= LINE: ' .. linenum  ..
	    '\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- \n'
	last.func = funcname
	last.linenum = linenum
    end
    r.ShowConsoleMsg(msg .. format(tostring(str), table.unpack(arg)) .. '\n')
end

--  ___ ____ ___  ___ _______ _/ / / _/_ _____  ____/ /_(_)__  ___  ___
-- / _ `/ -_) _ \/ -_) __/ _ `/ / / _/ // / _ \/ __/ __/ / _ \/ _ \(_-<
-- \_, /\__/_//_/\__/_/  \_,_/_/ /_/ \_,_/_//_/\__/\__/_/\___/_//_/___/
--/___/
-- Requires no namespace XXX
-- TODO: Possibly add in things like `is_half(x)`...will require a refactor of some
-- functions using the `...` arg

function std.is_even(a)     return a % 2 == 0 end

function std.is_odd(a)      return a % 2 == 1 end

function std.is_nil(a)      return a == nil   end

function std.is_half(a)     return a * .5     end

function std.is_positive(a) return a > 0      end

function std.is_negatve(a)  return a < 0      end

function std.is_double(a)   return a * 2      end

function std.is_itself(a)   return a          end


--   __                                         __
--  / /__ ___ ___   ___ ____ ___  ___ _______ _/ /
-- / / -_|_-<(_-<  / _ `/ -_) _ \/ -_) __/ _ `/ /
--/_/\__/___/___/  \_, /\__/_//_/\__/_/  \_,_/_/
--                /___/
-- will require namespaces! XXX

function std.table.has_key(tbl, query) return tbl[query] ~= nil end

function std.table.has_value(tbl, query)
    for _, v in pairs(tbl) do
        if v == query then return true end
    end
    return false
end

function std.table.are_equal(tbl_one, tbl_two)
    std.dbg('First = ' .. std.table.humanize(tbl_one))
    std.dbg('Second = ' .. std.table.humanize(tbl_two))
    local a = std.table.is_proper_subset(tbl_one, tbl_two)
    local b = std.table.is_proper_subset(tbl_two, tbl_one)
    if a and b then return true else return false end
end

function std.table.is_proper_subset(tbl_one, tbl_two)
    for k, _ in pairs(tbl_two) do
        if tbl_one[k] ~= tbl_two[k] then return false end
    end
    return true
end

function std.table.humanize(tbl, indent)
    indent = indent or ''
    local s = {indent .. 'TABLE {'}
    local i = 2
    indent = indent .. '  '
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            s[i] = format(indent .. 'Key = %s\tValue = \n%s', k, std.table.humanize(v, indent .. '\t'))
        else
            s[i] = format(indent .. 'Key = %s\tValue:\t%s', k, tostring(v))
        end
        i = i + 1
    end
    s[i] = (indent .. '}'):sub(2)
    return table.concat(s, '\n')
end

function std.table.purge(tbl)
    local i = 1
    local retable = {}

    for k, v in pairs(tbl) do
        if type(v) == 'table' then std.table.purge(v) end

        if type(k) == 'number' then
            retable[i] = v
            i = i + 1
        else
            retable[k] = v
        end
    end
    return retable
end

function std.table.clone(tbl)
    local clone = {}
    for k, v in pairs(tbl) do
        if type(v) == 'table' then v = std.table.clone(v) end

        clone[k] = v
    end
    return clone
end

function std.table.count(tbl)
    local c = 0
    for _, _ in pairs(tbl) do c = c + 1 end
    return c
end

function std.table.any_of(tbl, condition)
    if type(condition) == 'function' then
        for _, v in pairs(tbl) do if condition(v) then return true end end
    else
        for _, v in pairs(tbl) do if condition then return true end end
    end
    return false
end

function std.table.all_of(tbl, condition)
    if type(condition) == 'function' then
        for _, v in pairs(tbl) do if not condition(v) then return false end end
    else
        for _, v in pairs(tbl) do if not condition then return false end end
    end
    return true
end

function std.table.slice(tbl, start, finish, skip) end
function std.table.perform(tbl, func, args) end

return std
