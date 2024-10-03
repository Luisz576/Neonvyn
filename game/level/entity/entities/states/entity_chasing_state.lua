local State = require "libraries.llove.state_machine".State
local pointsDis = require "libraries.llove.math".pointsDis

local EntityChasingState = setmetatable({}, State)
EntityChasingState.__index = EntityChasingState

-- constructor
function EntityChasingState:new(entity, distanceToStopChasing, idleState)
    local instance = {
        entity = entity,
        distanceToStopChasing = distanceToStopChasing,
        idleState = idleState
    }
    return setmetatable(instance, self)
end

-- enter
function EntityChasingState:enter(target)
    self.target = target
end

function EntityChasingState._chase(entity, entityX, targetX, entityY, targetY, disX, disY, distanceToChangeDirection)
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
function EntityChasingState:update(dt)
    if self.target ~= nil then
        local entityX, entityY = self.entity.rect:centerX(), self.entity.rect:centerY()
        local targetX, targetY = self.target.rect:centerX(), self.target.rect:centerY()
        local disX, disY = math.abs(entityX - targetX), math.abs(entityY - targetY)
        -- is close
        if pointsDis(self.entity.rect:center(), self.target.rect:center()) < self.distanceToStopChasing then
            self.stateMachine:change(self.idleState)
            return
        end

        self._chase(self.entity, entityX, targetX, entityY, targetY, disX, disY, self.distanceToStopChasing)
    else
        self.stateMachine:change(self.idleState)
    end
end

return EntityChasingState