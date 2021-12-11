#!/bin/env lua

local lfs = require ("lfs")

local L_OPEN = '```lua'
local L_CLOSE = '```'

local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local function allmd(path)
    local ans = {}
    local md = ".md"
    for filename in lfs.dir(path) do
        if (filename:sub(-#md) == md) then
            table.insert(ans, path..filename)
        end
    end
    return ans
end

local function md2lua(it)
    local L_IN = false
    local LN = 0

    local ans = {"#!/bin/env lua\n\n"}

    for line in it do
        LN = LN + 1
        if (line == L_OPEN and not L_IN) or (line == L_CLOSE and L_IN) then
            L_IN = not L_IN
            table.insert(ans, "\n")
            goto continue
        elseif (line == L_OPEN and L_IN) or (line == L_CLOSE and not L_IN) then
            error(string.format("codeblock error in line %d", LN))
        end

        if L_IN then
            table.insert(ans, line)
            table.insert(ans, "\n")
        else
            table.insert(ans, "--")
            if line ~= "" then
                table.insert(ans, " "..line)
            end
            table.insert(ans, "\n")
        end
        ::continue::
    end
    return table.concat(ans, "")
end

local SCRIPT_PATH = script_path()

for _, md_path in pairs(allmd(SCRIPT_PATH)) do
    local md = io.open(md_path, "r")
    local lua = io.open(md_path:sub(0, -#".md"-1)..".lua", "w")
    io.input(md)
    io.output(lua)
    io.write(md2lua(io.lines()))
    io.close(md)
    io.close(lua)
end