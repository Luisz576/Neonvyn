local Goal = {}
Goal.__index = Goal

-- constructor
function Goal:new(entity)
    local instance = {
        entity = entity
    }
    return setmetatable(instance, Goal)
end

-- update
function Goal:update(dt) end

return Goal