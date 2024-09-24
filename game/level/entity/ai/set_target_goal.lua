local Goal = require "game.level.entity.ai.goal"
local pointsDis = require "libraries.llove.math".pointsDis
local directionToPoint = require "libraries.llove.util".directionToPoint

local LookAtTargetGoal = setmetatable({}, Goal)
LookAtTargetGoal.__index = LookAtTargetGoal

-- constructor
function LookAtTargetGoal:new(entity, possibleTargets, visionGroups, viewDistance)
    local instance = Goal:new(entity)

    instance.possibleTargets = possibleTargets or {}
    instance.visionGroups = visionGroups or {}
    instance.viewDistance = viewDistance or 200

    return setmetatable(instance, LookAtTargetGoal)
end

-- is possible target
function LookAtTargetGoal:isPossibleTarget(possibleTarget)
    for _, posTar in pairs(self.possibleTargets) do
        if getmetatable(possibleTarget) == posTar then
            return true
        end
    end
    return false
end

-- update
function LookAtTargetGoal:update(dt)
    -- ?TODO: should change this
    -- vision groups
    local entityPos, spritePos, sprites
    for _, group in pairs(self.visionGroups) do
        sprites = group:sprites()
        for _, sprite in pairs(sprites) do
            if sprite ~= self.entity and self:isPossibleTarget(sprite) then
                entityPos = self.entity.rect:center()
                spritePos = sprite.rect:center()
                if pointsDis(entityPos, spritePos) < self.viewDistance then
                    self.entity.target = sprite
                    return
                end
            end
        end
    end
    self.entity.target = nil
end

return LookAtTargetGoal