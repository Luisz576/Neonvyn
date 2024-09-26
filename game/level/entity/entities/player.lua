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
local Hurtbox = require "game.components.hutbox"
local DamageType = require "game.components.damage_source".DamageType

local Player = setmetatable({}, LivingEntity)
Player.__index = Player

local PlayerConfiguration = {
    maxBaseHealth = 10,
    inventoryBaseSize = 5,
    baseReceivingDamageTime = 0.1,
    attackDistance = 40,
    playerBaseDamage = 2,
    criticalBasePercent = 10,
    criticalMultiplier = 2,
}

-- constructor
function Player:new(level, groups, collisionGroups, attackableGroup)
    local scale = 2
    local instance = LivingEntity:new(EntityType.HUMAN, EntityClassification.PEACEFUL, level, 17 * scale, 25 * scale, groups, collisionGroups, 1, 1, PlayerConfiguration.maxBaseHealth, PlayerConfiguration.baseReceivingDamageTime)

    -- attributes
    instance.canPickupItem = true

    -- components
    instance.inventory = Inventory:new(PlayerConfiguration.inventoryBaseSize, "Player's Inventory")
    instance.attackHurtbox = Hurtbox:new(instance, 0, 0, 17 * scale, 25 * scale, attackableGroup, instance, "_onAttackHurtboxJoin", nil)
    instance.attackHurtbox.actived = false

    -- attacking
    instance.attacking = false
    instance.attackingAlreadyTryGiveDamage = false

    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage("assets/entities/player.png")
    instance.sprite.grid = AnimationGrid:new(17, 25, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = scale
    instance.sprite.animationController = AnimationController:new({
        -- idle
        idle_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 1
        }), 8, 2),
        idle_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 2
        }), 8, 2),
        idle_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 3
        }), 8, 2),
        idle_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 2
        }), 8, 2):flipX(),
        -- walking
        walking_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 4
        }), 8, 2),
        walking_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2),
        walking_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 6
        }), 8, 2),
        walking_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2):flipX(),
        -- attacking
        attacking_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 7
        }), 15, 2),
        attacking_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 8
        }), 15, 2),
        attacking_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 9
        }), 15, 2),
        attacking_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 8
        }), 15, 2):flipX(),
    }, "idle_down", true)
    instance.sprite.direction = Direction.down
    -- shaders
    instance.sprite.shaders = {
        damage_flash = Shader:get("damage_flash")
    }

    return setmetatable(instance, self)
end

-- stop attacking
function Player:_stopAttacking()
    -- stop attacking
    self.attacking = false
    self.attackingAlreadyTryGiveDamage = false
    self.attackHurtbox.actived = false
end

-- start attacking
function Player:_attack()
    if not self.state.receivingDamage and not self.attacking then
        self.attacking = true
        self.attackingAlreadyTryGiveDamage = false
    end
end

-- input
function Player:_input()
    -- moviment controls
    -- move in x
    self.velocity.x = (love.keyboard.isDown("d") and 1 or 0) + (love.keyboard.isDown("a") and -1 or 0)
    -- move in y
    self.velocity.y = (love.keyboard.isDown("s") and 1 or 0) + (love.keyboard.isDown("w") and -1 or 0)
    -- try attack
    if love.keyboard.isDown("space") then
        self:_attack()
    end
end

-- animate
function Player:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.direction

    -- is moving
    if self:isMoving() then
        animationName = "walking"
    end

    -- is attacking
    if self.attacking then
        animationName = "attacking"
    end

    -- animation direction
    if self.velocity.x > 0 then
        animationDirection = Direction.right
    elseif self.velocity.x < 0 then
        animationDirection = Direction.left
    elseif self.velocity.y > 0 then
        animationDirection = Direction.down
    elseif self.velocity.y < 0 then
        animationDirection = Direction.up
    end

    -- save direction
    self.sprite.direction = animationDirection
    -- set animation
    self.sprite.animationController:change(animationName .. "_" .. animationDirection)
    -- update animation
    self.sprite.animationController:update(dt)
end

-- pickup item
---@return integer
function Player:pickupItem(item)
    if self.canPickupItem then
        -- TODO: make in just one line
        local remainingAmount = self.inventory:add(item)
        print(item:displayName(), " - ", item.amount - remainingAmount)
        return remainingAmount
    end
    return item.amount
end

-- calculate damage
function Player:_calculateDamageTo(sprite)
    if PlayerConfiguration.criticalBasePercent > math.random(1, 100) then
        return PlayerConfiguration.playerBaseDamage * PlayerConfiguration.criticalMultiplier
    end
    return PlayerConfiguration.playerBaseDamage
end

-- _onAttackHurtboxJoin
function Player:_onAttackHurtboxJoin(sprite)
    print(sprite, sprite.health)
    -- give the damage
    if sprite.health ~= nil then
        sprite.health:hurt(self:_calculateDamageTo(sprite), DamageType.BY_ENTITY, self)
    end
end

-- on die
function Player:_onDie(source)
    print("GAME OVER")
    -- super
    LivingEntity.destroy(self)
end

-- update components
function Player:updateComponents()
    -- attack hurtbox
    -- down
    if self.sprite.direction == Direction.down then
        self.attackHurtbox:setCenterX(self.rect:centerX())
        self.attackHurtbox.y = self.rect.y + PlayerConfiguration.attackDistance / 2
        self.attackHurtbox:setSize(self.rect.height, PlayerConfiguration.attackDistance)
    -- left
    elseif self.sprite.direction == Direction.left then
        self.attackHurtbox:setXY(self.rect.x - PlayerConfiguration.attackDistance / 2, self.rect.y)
        self.attackHurtbox:setSize(PlayerConfiguration.attackDistance, self.rect.height)
    -- right
    elseif self.sprite.direction == Direction.right then
        self.attackHurtbox:setXY(self.rect.x + PlayerConfiguration.attackDistance / 2, self.rect.y)
        self.attackHurtbox:setSize(PlayerConfiguration.attackDistance, self.rect.height)
    -- up
    else
        self.attackHurtbox:setCenterX(self.rect:centerX())
        self.attackHurtbox.y = self.rect.y - PlayerConfiguration.attackDistance / 2
        self.attackHurtbox:setSize(self.rect.height, PlayerConfiguration.attackDistance)
    end
    self.attackHurtbox:update()
end

-- attacking state
function Player:_attacking()
    self.velocity:set(0, 0)
    self.attackHurtbox.actived = false

    if self.sprite.animationController:animation():isFrame(2) then -- give damage
        if not self.attackingAlreadyTryGiveDamage then
            self.attackingAlreadyTryGiveDamage = true
            self.attackHurtbox.actived = true
        end
    elseif self.sprite.animationController:animation():isLastFrame() then -- stop animation
        self:_stopAttacking()
    end
end

-- onReceivingDamage
function Player:_onReceivingDamageState(dt)
    -- stop attacking if receiving damage
    self:_stopAttacking()
    -- super
    LivingEntity._onReceivingDamageState(self, dt)
end

-- state manager
function Player:_state(dt)
    self.canMove = true
    -- receiving damage
    if self.state.receivingDamage then
        self:_onReceivingDamageState(dt)
    -- attacking
    elseif self.attacking then
        self:_attacking()
    end
end

-- update
function Player:update(dt)
    -- input
    self:_input()
    -- state manager
    self:_state(dt)
    -- animate
    self:_animate(dt)
    -- hurtbox update
    self:updateComponents()
    -- call super
    LivingEntity.update(self, dt)
end

-- draw
function Player:draw()
    local needsToReplaceShader, oldShader = false, nil
    -- damage shader
    if self.state.receivingDamage then
        needsToReplaceShader = true
        oldShader = love.graphics:getShader()
        love.graphics.setShader(self.sprite.shaders.damage_flash)
        local percentOfReceivingDamage = (self.state.receivingDamageDelta / self.state.receivingDamageTime)
        -- intensity
        self.sprite.shaders.damage_flash:send("flash_intensity", percentOfReceivingDamage)
    end
    -- draw player sprite
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
    -- clear shader
    if needsToReplaceShader then
        love.graphics.setShader(oldShader)
    end
end

return Player