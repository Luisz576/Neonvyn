local Entity = require "game.level.entity.entity"

local NPEntity = setmetatable({}, Entity)
NPEntity.__index = NPEntity

-- constructor
function NPEntity:new(x, y, width, height, groups, hitboxRelationX, hitboxRelationY)
    local instance = Entity:new(x, y, width, height, groups, hitboxRelationX, hitboxRelationY)

    instance.goals = {}

    return setmetatable(instance, self)
end

-- add goal
function NPEntity:addGoal(goal)
    table.insert(self.goals, goal)
end

-- get goal
function NPEntity:getGoalByType(goal)
    for i = 1, #self.goals, 1 do
        if getmetatable(self.goals[i]) == goal then
            return self.goals[i]
        end
    end
    return nil
end

-- remove goal
function NPEntity:removeGoal(goal)
    for i = 1, #self.goals, 1 do
        if self.goals[i] == goal then
            table.remove(self.goals, i)
            return true
        end
    end
    return false
end

-- update
function NPEntity:update(dt)
    -- update goals
    for _, goal in pairs(self.goals) do
        goal:update(dt)
    end
    -- super
    Entity.update(self, dt)
end

return NPEntity