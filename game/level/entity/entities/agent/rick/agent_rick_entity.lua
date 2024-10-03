local AgentEntity = require "game.level.entity.entities.agent.agent_entity"

local AgentRickEntity = setmetatable({}, AgentEntity)
AgentRickEntity.__index = AgentRickEntity

---@type AgentData
local AgentRickData = {
    name = "Rick",
    width = 34,
    height = 50,
    maxBaseHealth = 10,
    inventoryBaseSize = 5,
    baseReceivingDamageTime = 0.1,
    attackDistance = 40,
    baseDamage = 2,
    criticalBasePercent = 10,
    criticalMultiplier = 2,
    sprite = {
        scale = 2,
        width = 17,
        height = 25
    },
    animations = {
        idle = {
            frameXInterval = '1-6',
            frameYInterval = 1,
            speed = 8,
        },
        walking = {
            frameXInterval = '1-6',
            frameYInterval = 2,
            speed = 8,
        },
        attacking_1 = {
            frameXInterval = '1-4',
            frameYInterval = 3,
            speed = 15,
        }
    }
}

-- constructor
function AgentRickEntity:new(level, groups, collisionGroups, attackableGroup)
    local instance = AgentEntity:new(level, AgentRickData, groups, collisionGroups, attackableGroup)
    return setmetatable(instance, AgentEntity)
end

return AgentRickEntity