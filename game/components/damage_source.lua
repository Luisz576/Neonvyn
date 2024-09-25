-- DamageType
local DamageType = {
    UNKNOWN = 1,
    BY_SELF = 2,
    BY_ENTITY = 5
}

-- DamageSource
local DamageSource = {}
DamageSource.__index = DamageSource

-- constructor
function DamageSource:new(entity, damager, damage, damageType)
    local instance = {
        entity = entity,
        damager = damager,
        damage = damage,
        damageType = damageType or DamageType.UNKNOWN
    }
    return setmetatable(instance, self)
end

return {
    DamageSource = DamageSource,
    DamageType = DamageType
}