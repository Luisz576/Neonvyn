local LivingEntity = require "game.level.entity.living_entity"

local NPEntity = setmetatable({}, LivingEntity)
NPEntity.__index = NPEntity

-- constructor
function NPEntity:new(entityType, entityClassification, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)
    local instance = LivingEntity:new(entityType, entityClassification, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)

    instance.goals = {}

    return setmetatable(instance, self)
end

-- add goal
function NPEntity:addGoal(goal, priority)
    goal.priority = priority or (#self.goals + 1)
    table.insert(self.goals, goal)
    table.sort(self.goals, function (a, b) return a.priority < b.priority end)
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
function NPEntity:updateGoals(dt)
    -- update goals
    for _, goal in pairs(self.goals) do
        goal:update(dt)
    end
end

return NPEntity