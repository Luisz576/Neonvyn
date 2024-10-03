local Goal = require "game.level.entity.ai.goal"
local pointsDis = require "libraries.llove.math".pointsDis

local ChaseTargetGoal = setmetatable({}, Goal)
ChaseTargetGoal.__index = ChaseTargetGoal

-- constructor
function ChaseTargetGoal:new(entity, distanceToChangeDirection, distanceToStopChasing)
    local instance = Goal:new(entity)

    instance.distanceToChangeDirection = distanceToChangeDirection or 10
    instance.distanceToStopChasing = distanceToStopChasing or 20

    return setmetatable(instance, self)
end

function ChaseTargetGoal._chase(entity, entityX, targetX, entityY, targetY, disX, disY, distanceToChangeDirection)
    -- x chase
    if entityX > targetX then
        if entity.velocity.x ~= 0 then
            if disX > distanceToChangeDirection then
                entity.velocity.x = -1
            end
        else
            entity.velocity.x = -1
        end
    elseif entityX < targetX then
        if entity.velocity.x ~= 0 then
            if disX > distanceToChangeDirection then
                entity.velocity.x = 1
            end
        else
            entity.velocity.x = 1
        end
    else
        entity.velocity.x = 0
    end

    -- y chase
    if entityY > targetY then
        if entity.velocity.y ~= 0 then
            if disY > distanceToChangeDirection then
                entity.velocity.y = -1
            end
        else
            entity.velocity.y = -1
        end
    elseif entityY < targetY then
        if entity.velocity.y ~= 0 then
            if disY > distanceToChangeDirection then
                entity.velocity.y = 1
            end
        else
            entity.velocity.y = 1
        end
    else
        entity.velocity.y = 0
    end
end

-- update
function ChaseTargetGoal:update(dt)
    if self.entity.target ~= nil then
        local entityX, entityY = self.entity.rect:centerX(), self.entity.rect:centerY()
        local targetX, targetY = self.entity.target.rect:centerX(), self.entity.target.rect:centerY()
        local disX, disY = math.abs(entityX - targetX), math.abs(entityY - targetY)
        local distanceToChangeDirection, distanceToStopChasing = self.distanceToChangeDirection, self.distanceToStopChasing

        -- is close
        if pointsDis(self.entity.rect:center(), self.entity.target.rect:center()) < distanceToStopChasing then
            self.entity.velocity.x = 0
            self.entity.velocity.y = 0
            return
        end

        self._chase(self.entity, entityX, targetX, entityY, targetY, disX, disY, distanceToChangeDirection)
    else
        self.entity.velocity.x = 0
        self.entity.velocity.y = 0
    end
end

return ChaseTargetGoal