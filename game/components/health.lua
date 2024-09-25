local DamageSource = require "game.components.damage_source".DamageSource
local DamageType = require "game.components.damage_source".DamageType

local Health = {}
Health.__index = Health

-- constructor
---@param maxHealth number
---@param initialHealth number | nil
function Health:new(entity, maxHealth, initialHealth)
    maxHealth = maxHealth or 1
    local instance = {
        entity = entity,
        mh = maxHealth,
        h = initialHealth or maxHealth,
        _listeners = {}
    }
    return setmetatable(instance, self)
end

-- add listener
---@param listener any
---@param onHealFunctionName string | nil
---@param onHurtFunctionName string | nil
function Health:addListener(listener, onHealFunctionName, onHurtFunctionName)
    table.insert(self._listeners, {listener, onHealFunctionName, onHurtFunctionName})
end

-- remove listener
---@param listener any
function Health:removeListener(listener)
    for k, l in pairs(self._listeners) do
        if l[1] == listener then
            return table.remove(self._listeners, k)
        end
    end
    return nil
end

-- heal
function Health:heal(value, htype, healer)
    local damageSource = DamageSource:new(self.entity, healer, value, htype or DamageType.BY_SELF)
    self.h = math.min(self.h + damageSource.damage, self.mh)
    for _, l in pairs(self._listeners) do
        if l[2] ~= nil then
            l[1][l[2]](l[1], damageSource)
        end
    end
end

-- hurt
function Health:hurt(value, dtype, damager)
    local damageSource = DamageSource:new(self.entity, damager, value, dtype or DamageType.UNKNOWN)
    self.h = math.max(self.h - damageSource.damage, 0)
    for _, l in pairs(self._listeners) do
        if l[3] ~= nil then
            l[1][l[3]](l[1], damageSource)
        end
    end
end

return Health