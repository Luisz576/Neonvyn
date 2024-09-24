local Goal = require "game.level.entity.ai.goal"
local pointsDis = require "libraries.llove.math".pointsDis

local TriggerTargetDistanceGoal = setmetatable({}, Goal)
TriggerTargetDistanceGoal.__index = TriggerTargetDistanceGoal

-- constructor
function TriggerTargetDistanceGoal:new(entity, rangeDistance, functionHandlerName)
    local instance = Goal:new(entity)

    self.trigged = false
    self.rangeDistance = rangeDistance
    self.functionHandlerName = functionHandlerName

    return setmetatable(instance, self)
end

-- reset delay
function TriggerTargetDistanceGoal:resetTrigger()
    self.trigged = false
end

-- update
function TriggerTargetDistanceGoal:update(dt)
    if not self.trigged and self.entity.target ~= nil then
        if pointsDis(self.entity.rect:center(), self.entity.target.rect:center()) < self.rangeDistance then
            self.entity[self.functionHandlerName](self.entity, self.entity.target)
            self.trigged = true
        end
    end
end

return TriggerTargetDistanceGoal