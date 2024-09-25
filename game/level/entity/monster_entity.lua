local NPEntity = require "game.level.entity.npentity"
local EntityClassification = require "game.level.entity.entity_classification"

local MonsterEntity = setmetatable({}, NPEntity)
MonsterEntity.__index = MonsterEntity

-- constructor
function MonsterEntity:new(entityType, x, y, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)
    local instance = NPEntity:new(entityType, EntityClassification.AGGRESSIVE, x, y, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)
    return setmetatable(instance, self)
end

-- stop attacking
function MonsterEntity:_stopAttacking()
    -- stop attacking
    self.attacking = false
    self.attackingAlreadyTryGiveDamage = false
    self.attackingTarget = nil
end

-- calculate the amount of damage
function MonsterEntity:_calculateDamageTo(sprite)
    if self.criticalBasePercent > math.random(1, 100) then
        return self.damage * self.criticalMultiplier
    end
    return self.damage
end

-- attack handler
function MonsterEntity:_attackHandler(target)
    self.attackingTarget = target
    self.attacking = true
end

return MonsterEntity