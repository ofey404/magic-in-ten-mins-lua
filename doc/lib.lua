local debug = require ("debug")

local function getupperobj(name)
    local obj = nil

    -- Get local variable from upper environment.
    local i = 1
    while true do
        local uppername, value = debug.getlocal(3, i)
        if not uppername then
            error("Error: Name \""..name.."\" is not in upper environment.")
        end
        if uppername == name then
            obj = value
            break
        end
        i = i + 1
    end
    return obj
end

local function initclass(name)
    local obj = getupperobj(name)

    if type(obj) ~= "table" then
        error("Error: Name \""..name.."\" is not a table.")
    end

    obj.new = function (self, obj)
        obj = obj or {}
        self.__index = self
        setmetatable(obj, self)
        return obj
    end
    obj.type = name
end

local function inherit(parent, child_name, fields)
    local obj = parent:new(fields)
    obj.type = parent.type..":"..child_name
    return obj
end

return {
    class = initclass,
    inherit = inherit,
}
