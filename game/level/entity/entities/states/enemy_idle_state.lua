local State = require "libraries.llove.state_machine".State
local pointsDis = require "libraries.llove.math".pointsDis

local EnemyIdle = setmetatable({}, State)
EnemyIdle.__index = EnemyIdle

-- constructor
function EnemyIdle:new(entity, delayToWalk, distanceToChase, targetGroup, chaseState)
    local instance = {
        entity = entity,
        delayToWalk = delayToWalk,
        deltaToWalk = 0,
        distanceToChase = distanceToChase,
        targetGroup = targetGroup,
        chaseState = chaseState or "chasing"
    }
    EnemyIdle.calcNewDelayToWalk(instance)
    return setmetatable(instance, EnemyIdle)
end

-- walk
function EnemyIdle:calcNewDelayToWalk()
    if type(self.delayToWalk) == "table" then
        self.deltaToWalk = math.random(self.delayToWalk.min, self.delayToWalk.max)
    else
        self.deltaToWalk = self.delayToWalk
    end
end

-- update
function EnemyIdle:update(dt)
    -- TODO: BUG HERE
    -- reset speed
    self.entity.velocity.x = 0
    self.entity.velocity.y = 0
    -- walk around
    self.deltaToWalk = self.deltaToWalk - dt
    if self.deltaToWalk < 0 then
        -- TODO: Move
        print("!!!! TODO: MOVE !!!!")
        self:calcNewDelayToWalk()
    end

    -- target
    local entityPos, spritePos = self.entity.rect:center(), nil
    for _, sprite in pairs(self.targetGroup:sprites()) do
        spritePos = sprite.rect:center()
        if pointsDis(spritePos, entityPos) < self.distanceToChase then
            self.stateMachine:change(self.chaseState, sprite)
            return
        end
    end
end

return EnemyIdle