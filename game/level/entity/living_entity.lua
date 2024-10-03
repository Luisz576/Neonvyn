local Entity = require "game.level.entity.entity"
local Health = require "game.components.health"

local LivingEntity = setmetatable({}, Entity)
LivingEntity.__index = LivingEntity

-- constructor
-- TODO: remove instance.state
function LivingEntity:new(entityType, entityClassification, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY, maxHealth)
    local instance = Entity:new(entityType, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)

    -- attributes
    instance.invulnerable = false
    instance.entityClassification = entityClassification
    instance.dropLootType = 0

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
function LivingEntity:_onDie(source)
    self:_dropLoot()
    self:destroy()
end

-- drop loot
function LivingEntity:_dropLoot()
    if self.dropLootType > 0 then
        if self.dropLootType == 1 then
            -- TODO: load loot table
        elseif self.dropLootType == 2 then
            if self.inventory then
                -- TODO: drop items from inventory
            end
        end
    end
end

-- on get healed
function LivingEntity:_onHeal(source) end
-- on get hurted
function LivingEntity:_onHurt(source)
    -- verification if can receive damage
    if not self.invulnerable then
        print(self.health.h .. " / " .. self.health.mh)
        if self.health.h <= 0 then
            self:_onDie(source)
        end
    end
end

return LivingEntity