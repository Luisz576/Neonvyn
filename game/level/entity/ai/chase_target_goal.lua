local Goal = require "game.level.entity.ai.goal"

local ChaseTargetGoal = setmetatable({}, Goal)
ChaseTargetGoal.__index = ChaseTargetGoal

-- constructor
function ChaseTargetGoal:new(entity, distanceToChangeDirection, distanceToStopChasing)
    local instance = Goal:new(entity)

    instance.distanceToChangeDirection = distanceToChangeDirection or 10
    instance.distanceToStopChasing = distanceToStopChasing or 8

    return setmetatable(instance, self)
end

-- update
function ChaseTargetGoal:update(dt)
    if self.entity.target ~= nil then
        local entityX, entityY = self.entity.rect.x, self.entity.rect.y
        local targetX, targetY = self.entity.target.rect.x, self.entity.target.rect.y
        local disX, disY = math.abs(entityX - targetX), math.abs(entityY - targetY)
        local distanceToChangeDirection, distanceToStopChasing = self.distanceToChangeDirection, self.distanceToStopChasing

        if disX < distanceToStopChasing and disY < distanceToStopChasing then
            self.entity.velocity.x = 0
            self.entity.velocity.y = 0
            return
        end

        -- x chase
        if entityX > targetX then
            if self.entity.velocity.x ~= 0 then
                if disX > distanceToChangeDirection then
                    self.entity.velocity.x = -1
                end
            else
                self.entity.velocity.x = -1
            end
        elseif entityX < targetX then
            if self.entity.velocity.x ~= 0 then
                if disX > distanceToChangeDirection then
                    self.entity.velocity.x = 1
                end
            else
                self.entity.velocity.x = 1
            end
        else
            self.entity.velocity.x = 0
        end

        -- y chase
        if entityY > targetY then
            if self.entity.velocity.y ~= 0 then
                if disY > distanceToChangeDirection then
                    self.entity.velocity.y = -1
                end
            else
                self.entity.velocity.y = -1
            end
        elseif entityY < targetY then
            if self.entity.velocity.y ~= 0 then
                if disY > distanceToChangeDirection then
                    self.entity.velocity.y = 1
                end
            else
                self.entity.velocity.y = 1
            end
        else
            self.entity.velocity.y = 0
        end
    end
end

return ChaseTargetGoal