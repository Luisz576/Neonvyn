local Entity = require "game.level.entity.entity"
local Health = require "game.components.health"

local LivingEntity = setmetatable({}, Entity)
LivingEntity.__index = LivingEntity

-- constructor
function LivingEntity:new(entityType, entityClassification, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY, maxHealth)
    local instance = Entity:new(entityType, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)

    -- attributes
    instance.entityClassification = entityClassification

    -- components
    instance.health = Health:new(instance, maxHealth)
    instance.health:addListener(instance, "_onHeal", "_onHurt")

    return setmetatable(instance, self)
end

-- current health
function LivingEntity:getHealth()
    return self.health.h
end

-- on die
function LivingEntity:_onDie(source) end

-- on get healed
function LivingEntity:_onHeal(source) end
-- on get hurted
function LivingEntity:_onHurt(source)
    if self.health.h <= 0 then
        self:_onDie(source)
    end
end

return LivingEntity