-- Lib: Simulate a simple type system.
-- object.type is the type tag, eg: Expr:App

local function initclass(name, obj)
    obj = obj or {}

    obj.new = function (self, obj)
        obj = obj or {}
        self.__index = self
        setmetatable(obj, self)
        return obj
    end
    obj.type = name
    return obj
end

local function inherit(parent, child_name, newfields)
    newfields = newfields or {}
    local obj = parent:new(newfields)
    obj.type = parent.type..":"..child_name
    return obj
end

return {
    class = initclass,
    inherit = inherit,
}
