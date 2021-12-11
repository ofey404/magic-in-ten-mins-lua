#!/bin/env lua

local L_OPEN = '```lua'
local L_CLOSE = '```'

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

io.write(md2lua(io.lines()))