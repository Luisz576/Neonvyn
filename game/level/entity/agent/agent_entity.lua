local love = require "love"
local Direction = require "libraries.llove.util".Direction
local LivingEntity = require "game.level.entity.living_entity"
local EntityType = require "game.level.entity.entity_type"
local EntityClassification = require "game.level.entity.entity_classification"
local Inventory = require "game.level.inventory.inventory"

local AgentEntity = setmetatable({}, LivingEntity)
AgentEntity.__index = AgentEntity

---@class AgentData
---@field name string
---@field width number
---@field height number
---@field maxBaseHealth integer
---@field inventoryBaseSize integer
---@field sprite { scale: number, width: number, height: number }

-- constructor
---@param agentData AgentData
function AgentEntity:new(level, groups, agentData)
    local instance = LivingEntity:new(EntityType.HUMAN, EntityClassification.PEACEFUL, level, agentData.width, agentData.height, groups, agentData.maxBaseHealth)

    -- attributes
    instance.canPickupItem = true

    -- components
    instance.inventory = Inventory:new(agentData.inventoryBaseSize, "Agent's Inventory")

    return setmetatable(instance, self)
end

-- input
function AgentEntity:_input()
    -- moviment controls
    -- move in x
    self.velocity.x = (love.keyboard.isDown("d") and 1 or 0) + (love.keyboard.isDown("a") and -1 or 0)
    -- move in y
    self.velocity.y = (love.keyboard.isDown("s") and 1 or 0) + (love.keyboard.isDown("w") and -1 or 0)
end

-- animate
function AgentEntity:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.direction

    -- is moving
    if self:isMoving() then
        animationName = "walking"
    end

    -- is attacking
    if self.attacking then
        animationName = "attacking_1"
    end

    -- animation direction
    if self.velocity.x > 0 then
        animationDirection = Direction.right
    elseif self.velocity.x < 0 then
        animationDirection = Direction.left
    end
    self.sprite.direction = animationDirection

    -- set animation
    self.sprite.animationController:change(animationName)
    self.sprite.animationController:animation().flippedX = (animationDirection == Direction.left)
    -- update animation
    self.sprite.animationController:update(dt)
end

-- pickup item
---@return integer
function AgentEntity:pickupItem(item)
    if self.canPickupItem then
        -- TODO: make in just one line
        local remainingAmount = self.inventory:add(item)
        print(item:displayName(), " - ", item.amount - remainingAmount)
        return remainingAmount
    end
    return item.amount
end

-- on die
function AgentEntity:_onDie(source)
    print("GAME OVER")
    -- super
    LivingEntity.destroy(self)
end

-- state manager
function AgentEntity:_state(dt)
    -- super
    LivingEntity._state(self, dt)
end

-- update
function AgentEntity:update(dt)
    -- input
    self:_input()
    -- call super
    LivingEntity.update(self, dt)
end

return AgentEntity