local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local NPEntity = require "game.level.entity.npentity"
local EntityType = require "game.level.entity.entity_type"
local Groups = require "game.groups"
-- goals
local ChaseTargetGoal = require "game.level.entity.ai.chase_target_goal"
local SetTargetGoal = require "game.level.entity.ai.set_target_goal"
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
        spriteFrameHeight = 18,
        spriteScale = 2,
        -- sprite fix when render
        spriteFixX = -6,
        spriteFixY = -12,
        -- goals configuration
        goalsConfiguration = {
            viewDistance = 250
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
    instance.slime.deltaMove = slimeData.delayToMove

    -- attributes
    instance.speed = slimeData.speed

    -- groups
    instance.entityGroup = instance.getGroup(instance, Groups.ENTITY)

    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage(slimeData.spriteSheetPath)
    instance.sprite.grid = AnimationGrid:new(slimeData.spriteFrameWidth, slimeData.spriteFrameHeight, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = slimeData.spriteScale
    instance.sprite.animationController = AnimationController:new({
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
    -- set_target_goal
    self:addGoal(SetTargetGoal:new(self, {Player}, {self.entityGroup}, self.goalsConfiguration.viewDistance))
    -- chase_target_goal
    self:addGoal(ChaseTargetGoal:new(self))
end

-- animate
function Slime:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.direction

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

-- update
function Slime:update(dt)
    -- update animation
    self:_animate(dt)

    -- update goals
    self:updateGoals(dt)

    -- slime behavior
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

    -- super
    NPEntity.update(self, dt)
end

-- draw
function Slime:draw()
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x + self.sprite.spriteFixX, self.rect.y + self.sprite.spriteFixY, nil, self.sprite.scale)
end

return {
    Slime = Slime,
    SlimeData = SlimeData
}