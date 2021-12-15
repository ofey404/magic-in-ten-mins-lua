#!/bin/env lua

local L_OPEN = '```lua'
local L_CLOSE = '```'

local function md2lua(it)
    local CODEBLOCK = false
    local LINENUMBER = 0

    local ans = {"#!/bin/env lua\n\n"}

    for line in it do
        LINENUMBER = LINENUMBER + 1
        if (line == L_OPEN and not CODEBLOCK) or (line == L_CLOSE and CODEBLOCK) then
            CODEBLOCK = not CODEBLOCK
            table.insert(ans, "-- "..line.."\n")
            goto continue
        elseif (line == L_OPEN and CODEBLOCK) or (line == L_CLOSE and not CODEBLOCK) then
            error(string.format("codeblock error in line %d", LINENUMBER))
        end

        if CODEBLOCK then
            table.insert(ans, line.."\n")
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

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function lua2md(it)
    local CODEBLOCK = false
    local LINENUMBER = 0

    local ans = {}

    local first_line = true
    for line in it do
        if first_line then
            if line == "#!/bin/env lua" then goto continue end
            first_line = false
        end
        if (not CODEBLOCK) then
        else
        end
        if (CODEBLOCK) then
            if (line == "-- "..L_CLOSE) then
                table.insert(ans, L_CLOSE.."\n")
                CODEBLOCK = false
            else
                table.insert(ans, line.."\n")
            end
        else
            if (line == "-- "..L_OPEN) then
                table.insert(ans, L_OPEN.."\n")
                CODEBLOCK = true
            elseif (starts_with(line, "-- ")) then
                table.insert(ans, line:sub(4, #line).."\n")
            else
                table.insert(ans, "\n")
            end
        end
        ::continue::
    end
    return table.concat(ans, "")
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

