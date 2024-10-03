local State = require "libraries.llove.state_machine".State

local EntityWalkAroundState = setmetatable({}, State)
EntityWalkAroundState.__index = EntityWalkAroundState

-- constructor
function EntityWalkAroundState:new(entity, delayToWalk)
    local instance = {
        entity = entity,
        delayToWalk = delayToWalk,
        deltaToWalk = 0
    }
    EntityWalkAroundState.calcNewDelayToWalk(instance)
    return setmetatable(instance, EntityWalkAroundState)
end

-- walk
function EntityWalkAroundState:calcNewDelayToWalk()
    if type(self.delayToWalk) == "table" then
        self.deltaToWalk = math.random(self.delayToWalk.min, self.delayToWalk.max)
    else
        self.deltaToWalk = self.delayToWalk
    end
end

-- update
function EntityWalkAroundState:update(dt)
    self.deltaToWalk = self.deltaToWalk - dt
    if self.deltaToWalk < 0 then
        -- TODO: Move
        print("!!!! TODO: MOVE !!!!")
        self:calcNewDelayToWalk()
    end
end

return EntityWalkAroundState