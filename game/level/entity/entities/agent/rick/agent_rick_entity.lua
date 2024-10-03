local AgentEntity = require "game.level.entity.entities.agent.agent_entity"

local AgentRickEntity = setmetatable({}, AgentEntity)
AgentRickEntity.__index = AgentRickEntity

---@type AgentData
local AgentRickData = {
    name = "Rick",
    maxBaseHealth = 10,
    inventoryBaseSize = 5,
    baseReceivingDamageTime = 0.1,
    attackDistance = 40,
    baseDamage = 2,
    criticalBasePercent = 10,
    criticalMultiplier = 2,
}

function AgentRickEntity:new(level, groups, collisionGroups, attackableGroup)
    local instance = AgentEntity:new(level, AgentRickData, groups, collisionGroups, attackableGroup)
    return setmetatable(instance, AgentEntity)
end

return AgentRickEntity