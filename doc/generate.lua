#!/bin/env lua

local function lineequal(line, expect)
    if line == expect then
        return true
    else
        return false
    end
end

local function mapinblock(it, config)
    local INBLOCK = config.initinblock
    local LINENUMBER = 0
    local ans = {}

    for line in it do
        LINENUMBER = LINENUMBER + 1
        if (config.isopen(line) and not INBLOCK) then
            if config.containborder then
                table.insert(ans, config.mapinblock(line))
            else
                table.insert(ans, config.mapoutblock(line))
            end
            INBLOCK = true
        elseif (config.isclose(line) and INBLOCK) then
            if config.containborder then
                table.insert(ans, config.mapinblock(line))
            else
                table.insert(ans, config.mapoutblock(line))
            end
            INBLOCK = false
        elseif (config.isopen(line) and INBLOCK) or (config.isclose(line) and not INBLOCK) then
            error(string.format("block mismatch in line %d", LINENUMBER))
        else
            if INBLOCK then
                table.insert(ans, config.mapinblock(line))
            else
                table.insert(ans, config.mapoutblock(line))
            end
        end
    end
    return ans
end

local function md2lua(it)
    local md2luaconfig = {
        initinblock = false,
        isopen = function (line) return lineequal(line, '```lua') end,
        isclose = function (line) return lineequal(line, '```') end,
        mapinblock = function (line) return line end,
        mapoutblock = function (line) 
            if line == "" then
                return "--"
            else
                return "-- "..line
            end
        end,
        blockcontainborder = false,
    }
    return table.concat(mapinblock(io.lines(), md2luaconfig), "\n")
end

local function lua2md(it)
    local lua2mdconfig = {
        initinblock = false,
        isopen = function (line) return lineequal(line, '-- ```lua') end,
        isclose = function (line) return lineequal(line, '-- ```') end,
        mapinblock = function (line) return line end,
        mapoutblock = function (line) return line:sub(4, #line) end,
        blockcontainborder = false,
    }
    return table.concat(mapinblock(io.lines(), lua2mdconfig), "\n")
end


if (arg[1]) then
    if (arg[1] == "--lua2md") then
    io.write(lua2md(io.lines()))
    else
        io.write([[Usage:
    cat XXX.md | ./generate.lua > XXX.lua
    cat XXX.lua | ./generate.lua --lua2md > XXX.md
]])
    end
else
    io.write(md2lua(io.lines()))
end

