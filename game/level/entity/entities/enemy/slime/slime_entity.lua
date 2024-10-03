local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local pointsDis = require "libraries.llove.math".pointsDis
local LivingEntity = require "game.level.entity.living_entity"
local EntityType = require "game.level.entity.entity_type"
local EntityClassification = require "game.level.entity.entity_classification"
local Groups = require "game.groups"
local Shader = require "game.shader".Shader
local DamageType = require "game.components.damage_source".DamageType
-- states
local EntityWalkAroundState = require "game.level.entity.entities.states.entity_walk_around_state"

local SlimeEntity = setmetatable({}, LivingEntity)
SlimeEntity.__index = SlimeEntity

local SlimeData = {
    NORMAL = {
        width = 14,
        height = 10,
        hitboxRelationX = 1,
        hitboxRelationY = 1,
        entityClassification = EntityClassification.AGGRESSIVE,
        -- attributes
        speed = 80,
        maxHealth = 10,
        receivingDamageTime = 0.3,
        -- damage
        damage = 2,
        criticalMultiplier = 1.5,
        criticalBasePercent = 20,
        -- sprite and animation configuration
        spriteSheetPath = "assets/entities/slime.png",
        spriteFrameWidth = 20,
        spriteFrameHeight = 22,
        spriteScale = 2,
        -- sprite fix when render
        spriteFixX = -6,
        spriteFixY = -20,
        -- animations
        animations = {
            idle = {
                frameXInterval = '1-4',
                frameYInterval = 1,
                speed = 5,
            },
            walking = {
                frameXInterval = '1-6',
                frameYInterval = 2,
                speed = 8,
            },
            attacking_1 = {
                frameXInterval = '1-7',
                frameYInterval = 3,
                speed = 10,
            }
        },
        -- slime configuration
        delayToMove = 1.6
    }
}
SlimeData.__index = SlimeData

-- constructor
function SlimeEntity:new(level, groups, collisionGroups, slimeData)
    local instance = LivingEntity:new(EntityType.SLIME, slimeData.entityClassification, level, slimeData.width * slimeData.spriteScale, slimeData.height * slimeData.spriteScale, groups, collisionGroups, slimeData.hitboxRelationX, slimeData.hitboxRelationY, slimeData.maxHealth, slimeData.receivingDamageTime)

    -- slime attributes
    instance.slime = {}
    instance.slime.delayToMove = slimeData.delayToMove
    instance.slime.deltaMove = 0.01

    -- attributes
    instance.speed = slimeData.speed
    instance.damage = 2
    instance.criticalMultiplier = 1.5
    instance.criticalBasePercent = 10

    -- attacking
    instance.attacking = false
    instance.attackingAlreadyTryGiveDamage = false
    instance.attackingTarget = nil

    -- groups
    instance.entityGroup = instance.getGroup(instance, Groups.ENTITY)

    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage(slimeData.spriteSheetPath)
    instance.sprite.grid = AnimationGrid:new(slimeData.spriteFrameWidth, slimeData.spriteFrameHeight, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = slimeData.spriteScale
    local slimeAnimations = {}
    for name, config in pairs(slimeData.animations) do
        slimeAnimations[name] = Animation:new(instance.sprite.grid:frames({
            frameXInterval = config.frameXInterval,
            frameYInterval = config.frameYInterval
        }), config.speed, slimeData.spriteScale)
    end
    instance.sprite.animationController = AnimationController:new(slimeAnimations, "idle", true)
    instance.sprite.direction = Direction.right
    -- shaders
    instance.sprite.shaders = {
        damage_flash = Shader:get("damage_flash")
    }

    -- sprite fix
    instance.sprite.spriteFixX = slimeData.spriteFixX or 0
    instance.sprite.spriteFixY = slimeData.spriteFixY or 0

    -- states
    SlimeEntity._registerStates(instance)
    instance.stateMachine:change("idle")

    return setmetatable(instance, self)
end

-- register states
function SlimeEntity:_registerStates()
    -- idle
    self.stateMachine:registerState("idle", EntityWalkAroundState:new(self, { min = 1, max = 5 }))
end

-- animate
function SlimeEntity:_animate(dt)
    local animationName = "idle"

    -- is moving
    if self:isMoving() then
        animationName = "walking"
    end

    -- is attacking
    if self.attacking then
        animationName = "attacking_1"
    end

    -- animation direction
    local animationDirection = self.sprite.direction
    if self.velocity.x > 0 then
        animationDirection = Direction.right
    elseif self.velocity.x < 0 then
        animationDirection = Direction.left
    end
    self.sprite.direction = animationDirection
    self.sprite.animationController:animation().flippedX = (animationDirection == Direction.left)

    -- set animation
    self.sprite.animationController:change(animationName)
    -- update animation
    self.sprite.animationController:update(dt)
end

-- TODO: remove this kind of attack and replace by many attack types
-- stop attacking
function SlimeEntity:_stopAttacking()
    -- reset trigger
    self.goalsConfiguration.attackTriggerGoal:reset()
    -- stop attacking
    self.attacking = false
    self.attackingAlreadyTryGiveDamage = false
    self.attackingTarget = nil
end

-- attacking logic
function SlimeEntity:_attacking()
    self.velocity:set(0, 0)

    if self.sprite.animationController:animation():isFrame(5) then -- give damage
        if not self.attackingAlreadyTryGiveDamage then
            local targetPos = self.attackingTarget.rect:center()
            if pointsDis(self.rect:center(), targetPos) <= self.goalsConfiguration.attackRange then
                self.attackingAlreadyTryGiveDamage = true
                if self.attackingTarget.health ~= nil then
                    -- really give the damage
                    self.attackingTarget.health:hurt(self:_calculateDamageTo(self.attackingTarget), DamageType.BY_ENTITY, self)
                end
            end
        end
    elseif self.sprite.animationController:animation():isLastFrame() then -- stop animation
        self:_stopAttacking()
    end
end

-- calculate the amount of damage
function SlimeEntity:_calculateDamageTo(sprite)
    if self.criticalBasePercent > math.random(1, 100) then
        return self.damage * self.criticalMultiplier
    end
    return self.damage
end

-- attack handler
function SlimeEntity:_attackHandler(target)
    self.attackingTarget = target
    self.attackingAlreadyTryGiveDamage = false
    self.attacking = true
end

-- slime behaviour
function SlimeEntity:_slimeBehaviour(dt)
    -- jump delay
    if not self.velocity:isZero() then
        if self.slime.deltaMove > 0 then
            self.slime.deltaMove = self.slime.deltaMove - dt
            if self.slime.deltaMove > 0 then
                self.velocity:set(0, 0)
            end
        else
            if self.sprite.animationController:animation():remainingFrames() == 0 then
                self.slime.deltaMove = math.random(self.slime.delayToMove / 2 , self.slime.delayToMove)
            end
        end
    end
end

-- onReceivingDamage
function SlimeEntity:_onReceivingDamageState(dt)
    -- stop attacking if receiving damage
    self:_stopAttacking()
    -- super
    LivingEntity._onReceivingDamageState(self, dt)
end

-- state manager
function SlimeEntity:_state(dt)
    self.canMove = true
    -- receivingDamage
    if self.state.receivingDamage then
        self:_onReceivingDamageState(dt)
    -- attacking
    elseif self.attacking then
        self:_attacking()
    else
        -- slime behavior
        self:_slimeBehaviour(dt)
    end
end

-- update
function SlimeEntity:update(dt)
    -- states logic
    self:_state(dt)
    -- update animation
    self:_animate(dt)
    -- super
    LivingEntity.update(self, dt)
end

-- draw
function SlimeEntity:draw()
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
    -- draw sprite
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
    -- clear shader
    if needsToReplaceShader then
        love.graphics.setShader(oldShader)
    end
end

return {
    SlimeEntity = SlimeEntity,
    SlimeData = SlimeData
}