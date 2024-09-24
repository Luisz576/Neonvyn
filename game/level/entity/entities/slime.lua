local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local NPEntity = require "game.level.entity.npentity"
local EntityType = require "game.level.entity.entity_type"
-- goals
local ChaseTargetGoal = require "game.level.entity.ai.chase_target_goal"
local SetTargetGoal = require "game.level.entity.ai.set_target_goal"
local Player = require "game.level.entity.entities.player"
local Groups = require "game.groups"

local Slime = setmetatable({}, NPEntity)
Slime.__index = Slime

local SlimeData = {
    normal = {
        speed = 100,
        width = 14,
        height = 10,
        hitboxRelationX = 0.5,
        hitboxRelationY = 0.5
    }
}
SlimeData.__index = SlimeData

-- constructor
function Slime:new(x, y, groups, slimeData)
    local instance = NPEntity:new(EntityType.SLIME, x, y, slimeData.width, slimeData.height, groups, slimeData.hitboxRelationX, slimeData.hitboxRelationY)

    -- attributes
    instance.speed = slimeData.speed
    
    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage("assets/entities/slime.png")
    instance.sprite.grid = AnimationGrid:new(20, 18, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = 2
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

    instance.entityGroup = instance.getGroup(instance, Groups.ENTITY)

    Slime._registerGoals(instance)

    return setmetatable(instance, self)
end

-- register goals
function Slime:_registerGoals()
    -- chase_target_goal
    self:addGoal(SetTargetGoal:new(self, {Player}, {self.entityGroup}))
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
    -- super
    NPEntity.update(self, dt)
end

-- draw
function Slime:draw()
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
end

return {
    Slime = Slime,
    SlimeData = SlimeData
}