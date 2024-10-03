local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local LivingEntity = require "game.level.entity.living_entity"
local EntityType = require "game.level.entity.entity_type"
local EntityClassification = require "game.level.entity.entity_classification"
local SpriteComponent = require "game.components.sprite_component"
local Groups = require "game.groups"
local Shader = require "game.shader".Shader
-- states
local EnemyIdleState = require "game.level.entity.entities.states.enemy_idle_state"
local EntityChasingState = require "game.level.entity.entities.states.entity_chasing_state"

local SlimeEntity = setmetatable({}, LivingEntity)
SlimeEntity.__index = SlimeEntity

-- TODO: move to a new file "GreenSlimeEntity", "IceSlimeEntity", ...
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
        viewDistance = 100,
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
function SlimeEntity:new(level, groups, collisionGroups, agentsGroup, slimeData)
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
    instance.viewDistance = slimeData.viewDistance

    -- attacking
    instance.attacking = false
    instance.attackingAlreadyTryGiveDamage = false
    instance.attackingTarget = nil

    -- groups
    instance.entityGroup = instance.getGroup(instance, Groups.ENTITY)
    instance.agentsGroup = agentsGroup

    -- animationa
    instance.sprite = SpriteComponent:new(love.graphics.newImage(slimeData.spriteSheetPath), slimeData.spriteScale)
    instance.sprite.grid = AnimationGrid:new(slimeData.spriteFrameWidth, slimeData.spriteFrameHeight, instance.sprite.texture:getWidth(), instance.sprite.texture:getHeight())
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
    instance.sprite.offsetX = slimeData.spriteFixX or 0
    instance.sprite.offsetY = slimeData.spriteFixY or 0

    -- states
    SlimeEntity._registerStates(instance)
    instance.stateMachine:change("idle")

    return setmetatable(instance, self)
end

-- register states
function SlimeEntity:_registerStates()
    -- idle
    self.stateMachine:registerState("idle", EnemyIdleState:new(self, { min = 5, max = 10 }, self.viewDistance, self.agentsGroup, "chasing"))
    -- chase
    self.stateMachine:registerState("chasing", EntityChasingState:new(self, self.viewDistance, "idle", 20))
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
    
    -- set animation
    self.sprite.animationController:change(animationName)
    self.sprite.animationController:animation().flippedX = (animationDirection == Direction.left)
    -- update animation
    self.sprite.animationController:update(dt)
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

-- state manager
function SlimeEntity:_state(dt)
    self.canMove = true
    -- receivingDamage
    self:_slimeBehaviour(dt)
    -- super
    LivingEntity._state(self, dt)
end

-- draw
function SlimeEntity:draw()
    local needsToReplaceShader, oldShader = false, nil
    -- TODO: damage shader
    -- draw sprite
    self.sprite.animationController:draw(self.sprite.texture, self.rect.x, self.rect.y, nil, self.sprite.scale)
    -- clear shader
    if needsToReplaceShader then
        love.graphics.setShader(oldShader)
    end
end

return {
    SlimeEntity = SlimeEntity,
    SlimeData = SlimeData
}