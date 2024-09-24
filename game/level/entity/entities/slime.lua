local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local NPEntity = require "game.level.entity.npentity"
local EntityType = require "game.level.entity.entity_type"
local Groups = require "game.groups"
-- goals
local LookAtTargetGoal = require "game.level.entity.ai.look_at_target_goal"
local ChaseTargetGoal = require "game.level.entity.ai.chase_target_goal"
local SetTargetGoal = require "game.level.entity.ai.set_target_goal"
local TriggerTargetDistanceGoal = require "game.level.entity.ai.trigger_target_distance_goal"
local Player = require "game.level.entity.entities.player"

local Slime = setmetatable({}, NPEntity)
Slime.__index = Slime

local SlimeData = {
    NORMAL = {
        -- attributes
        speed = 80,
        width = 14,
        height = 10,
        hitboxRelationX = 1,
        hitboxRelationY = 1,
        -- sprite and animation configuration
        spriteSheetPath = "assets/entities/slime.png",
        spriteFrameWidth = 20,
        spriteFrameHeight = 22,
        spriteScale = 2,
        -- sprite fix when render
        spriteFixX = -6,
        spriteFixY = -20,
        -- goals configuration
        goalsConfiguration = {
            viewDistance = 250,
            attackRange = 55
        },
        -- slime configuration
        delayToMove = 1.6
    }
}
SlimeData.__index = SlimeData

-- constructor
function Slime:new(x, y, groups, collisionGroups, slimeData)
    local instance = NPEntity:new(EntityType.SLIME, x, y, slimeData.width * slimeData.spriteScale, slimeData.height * slimeData.spriteScale, groups, collisionGroups, slimeData.hitboxRelationX, slimeData.hitboxRelationY)

    -- slime attributes
    instance.slime = {}
    instance.slime.delayToMove = slimeData.delayToMove
    instance.slime.deltaMove = 0.01

    -- attributes
    instance.attacking = false
    instance.attackingTarget = nil
    instance.speed = slimeData.speed

    -- groups
    instance.entityGroup = instance.getGroup(instance, Groups.ENTITY)

    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage(slimeData.spriteSheetPath)
    instance.sprite.grid = AnimationGrid:new(slimeData.spriteFrameWidth, slimeData.spriteFrameHeight, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = slimeData.spriteScale
    instance.sprite.animationController = AnimationController:new({
        -- idle
        idle_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 1
        }), 5, 2),
        idle_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 2
        }), 5, 2),
        idle_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
            frameYInterval = 3
        }), 5, 2),
        idle_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-4',
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
            frameXInterval = '1-7',
            frameYInterval = 7
        }), 8, 2),
        attacking_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2),
        attacking_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2),
        attacking_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2):flipX(),
    }, "idle_down", true)
    instance.sprite.direction = Direction.down

    -- sprite fix
    instance.sprite.spriteFixX = slimeData.spriteFixX or 0
    instance.sprite.spriteFixY = slimeData.spriteFixY or 0

    -- slime goals
    instance.goalsConfiguration = slimeData.goalsConfiguration or {}
    Slime._registerGoals(instance)

    return setmetatable(instance, self)
end

-- register slime goals
function Slime:_registerGoals()
    -- look to target even stopped
    self:addGoal(LookAtTargetGoal:new(self, {Player}, {self.entityGroup}, self.goalsConfiguration.viewDistance))
    -- set_target_goal
    self:addGoal(SetTargetGoal:new(self, {Player}, {self.entityGroup}, self.goalsConfiguration.viewDistance))
    -- chase_target_goal
    self:addGoal(ChaseTargetGoal:new(self))
    -- attack trigger
    self.goalsConfiguration.attackTriggerGoal = TriggerTargetDistanceGoal:new(self, self.goalsConfiguration.attackRange, "_attackHandler")
    self:addGoal(self.goalsConfiguration.attackTriggerGoal)
end

-- animate
function Slime:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.direction

    -- is attacking
    if self.attacking then
        animationName = "attacking"
    end

    -- is moving
    if self:isMoving() then
        animationName = "walking"
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

-- attacking logic
function Slime:_attacking()
    self.velocity:set(0, 0)

    if self.sprite.animationController:animation():isFrame(3) then -- give damage
        -- if self.attackingTarget.rect:center() -- ?Look the distance to give damage
        -- TODO: give damage
    elseif self.sprite.animationController:animation():isLastFrame() then -- stop animation
        -- stop attacking
        self.slime.deltaMove = self.slime.delayToMove / 2
        self.attacking = false
        -- reset trigger
        self.goalsConfiguration.attackTriggerGoal:resetTrigger()
    end
end

-- slime behaviour
function Slime:_slimeBehaviour(dt)
    -- jump delay
    if not self.velocity:isZero() then
        if self.slime.deltaMove > 0 then
            self.slime.deltaMove = self.slime.deltaMove - dt
            if self.slime.deltaMove > 0 then
                self.velocity:set(0, 0)
            end
        else
            if self.sprite.animationController:animation():remainingFrames() == 0 then
                self.slime.deltaMove = self.slime.delayToMove
            end
        end
    end
end

-- update
function Slime:update(dt)
    -- update animation
    self:_animate(dt)

    -- update goals
    self:updateGoals(dt)

    if self.attacking then
        -- attacking
        self:_attacking()
    else
        -- slime behavior
        self:_slimeBehaviour(dt)
    end

    -- super
    NPEntity.update(self, dt)
end

-- attack handler
function Slime:_attackHandler(target)
    self.attackingTarget = target
    self.attacking = true
end

-- draw
function Slime:draw()
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x + self.sprite.spriteFixX, self.rect.y + self.sprite.spriteFixY, nil, self.sprite.scale)
    -- love.graphics.rectangle("fill", self.rect.x, self.rect.y, self.rect.width, self.rect.height)
    -- love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.width, self.hitbox.height)
end

return {
    Slime = Slime,
    SlimeData = SlimeData
}