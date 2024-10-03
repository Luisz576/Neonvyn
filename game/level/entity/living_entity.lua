local Entity = require "game.level.entity.entity"
local Health = require "game.components.health"

local LivingEntity = setmetatable({}, Entity)
LivingEntity.__index = LivingEntity

-- constructor
-- TODO: remove instance.state
function LivingEntity:new(entityType, entityClassification, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY, maxHealth, receivingDamageTime)
    local instance = Entity:new(entityType, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)

    -- attributes
    instance.invulnerable = false
    instance.entityClassification = entityClassification
    instance.dropLootType = 0

    -- state
    instance.state = instance.state or {}
    instance.state.receivingDamage = false
    instance.state.receivingDamageTime = receivingDamageTime or 0.1
    instance.state.receivingDamageDelta = 0

    -- components
    instance.health = Health:new(instance, maxHealth)
    instance.health:addListener(instance, "_onHeal", "_onHurt")

    return setmetatable(instance, self)
end

-- current health
function LivingEntity:getHealth()
    return self.health.h
end

-- stop receiving damage
function LivingEntity:_stopReceivingDamage()
    self.state.receivingDamageDelta = 0
    self.state.receivingDamage = false
end

-- onReceivingDamage
function LivingEntity:_onReceivingDamageState(dt)
    self.canMove = false
    self.state.receivingDamageDelta = self.state.receivingDamageDelta - dt
    -- stop receiving damage
    if self.state.receivingDamageDelta <= 0 then
        self:_stopReceivingDamage()
        self.canMove = true
    end
end

-- on die
function LivingEntity:_onDie(source)
    self:_dropLoot()
    self:destroy()
end

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
    if not self.state.receivingDamage and not self.invulnerable then
        -- set receiving damage state
        self.state.receivingDamage = true
        self.state.receivingDamageDelta = self.state.receivingDamageTime
        print(self.health.h .. " / " .. self.health.mh)
        if self.health.h <= 0 then
            self:_onDie(source)
        end
    end
end

return LivingEntity