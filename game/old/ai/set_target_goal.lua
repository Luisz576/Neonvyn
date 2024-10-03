local Goal = require "game.level.entity.ai.goal"
local pointsDis = require "libraries.llove.math".pointsDis
local isPossibleTarget = require "game.level.entity.ai.look_at_target_goal".isPossibleTarget

local SetTargetGoal = setmetatable({}, Goal)
SetTargetGoal.__index = SetTargetGoal

-- constructor
function SetTargetGoal:new(entity, possibleTargets, visionGroups, viewDistance)
    local instance = Goal:new(entity)

    instance.possibleTargets = possibleTargets or {}
    instance.visionGroups = visionGroups or {}
    instance.viewDistance = viewDistance or 200

    return setmetatable(instance, self)
end

-- update
function SetTargetGoal:update(dt)
    -- ?TODO: should change this
    -- vision groups
    local entityPos, spritePos, sprites
    for _, group in pairs(self.visionGroups) do
        sprites = group:sprites()
        for _, sprite in pairs(sprites) do
            if sprite ~= self.entity and isPossibleTarget(self, sprite) then
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

return SetTargetGoal