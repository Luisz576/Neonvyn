local State = require "libraries.llove.state_machine".State

local EnemyMeleeAttackState = setmetatable({}, State)
EnemyMeleeAttackState.__index = EnemyMeleeAttackState

-- constructor
function EnemyMeleeAttackState:new(entity)
    local instance = {
        entity = entity
        -- TODO:
    }
    return setmetatable(instance, self)
end

return EnemyMeleeAttackState