local love = require "love"
local Direction = require "libraries.llove.util".Direction
local Animation = require "libraries.llove.animation".Animation
local AnimationController = require "libraries.llove.animation".AnimationController
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local LivingEntity = require "game.level.entity.living_entity"
local EntityType = require "game.level.entity.entity_type"
local EntityClassification = require "game.level.entity.entity_classification"
local Shader = require "game.shader".Shader
local Inventory = require "game.level.inventory.inventory"
local SpriteComponent = require "game.components.sprite_component"
local Area2D = require "libraries.llove.component".Area2D
local DamageType = require "game.components.damage_source".DamageType

local AgentEntity = setmetatable({}, LivingEntity)
AgentEntity.__index = AgentEntity

-- TODO: organize this Agent Data
---@class AgentData
---@field name string
---@field width number
---@field height number
---@field maxBaseHealth integer
---@field inventoryBaseSize integer
---@field baseReceivingDamageTime number
---@field attackDistance integer
---@field baseDamage integer
---@field criticalBasePercent integer
---@field criticalMultiplier integer
---@field spriteScale number
---@field animations any

-- constructor
---@param agentData AgentData
function AgentEntity:new(level, agentData, groups, collisionGroups, attackableGroup)
    local instance = LivingEntity:new(EntityType.HUMAN, EntityClassification.PEACEFUL, level, agentData.width, agentData.height, groups, collisionGroups, 1, 1, agentData.maxBaseHealth, agentData.baseReceivingDamageTime)

    -- attributes
    instance.agentData = agentData
    instance.canPickupItem = true

    -- components
    instance.inventory = Inventory:new(agentData.inventoryBaseSize, "Agent's Inventory")

    -- animationa
    instance.sprite = SpriteComponent:new(love.graphics.newImage("assets/entities/player.png"), agentData.spriteScale)
    instance.sprite.grid = AnimationGrid:new(17, 25, instance.sprite.texture:getWidth(), instance.sprite.texture:getHeight())
    local agentAnimations = {}
    for name, config in pairs(agentData.animations) do
        agentAnimations[name] = Animation:new(instance.sprite.grid:frames({
            frameXInterval = config.frameXInterval,
            frameYInterval = config.frameYInterval
        }), config.speed, agentData.spriteScale)
    end
    instance.sprite.animationController = AnimationController:new(agentAnimations, "idle", true)
    instance.sprite.direction = Direction.right
    -- shaders
    instance.sprite.shaders = {
        damage_flash = Shader:get("damage_flash")
    }

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

-- calculate damage
function AgentEntity:_calculateDamageTo(sprite)
    if self.agentData.criticalBasePercent > math.random(1, 100) then
        return self.agentData.baseDamage * self.agentData.criticalMultiplier
    end
    return self.agentData.baseDamage
end

-- on die
function AgentEntity:_onDie(source)
    print("GAME OVER")
    -- super
    LivingEntity.destroy(self)
end

-- state manager
function AgentEntity:_state(dt)
    self.canMove = true
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

-- draw
function AgentEntity:draw()
    local needsToReplaceShader, oldShader = false, nil
    -- TODO: damage shader
    -- draw sprite
    self.sprite.animationController:draw(self.sprite.texture, self.rect.x, self.rect.y, nil, self.sprite.scale)
    -- clear shader
    if needsToReplaceShader then
        love.graphics.setShader(oldShader)
    end
end

return AgentEntity