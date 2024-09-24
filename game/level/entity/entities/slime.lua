local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local NPEntity = require "game.level.entity.npentity"
-- goals
local ChaseTargetGoal = require "game.level.entity.ai.chase_target_goal"

local Slime = setmetatable({}, NPEntity)
Slime.__index = Slime

local SlimeData = {
    normal = {
        speed = 100,
        width = 20,
        height = 20,
        hitboxRelationX = 0.8,
        hitboxRelationY = 0.8
    }
}
SlimeData.__index = SlimeData

-- constructor
function Slime:new(x, y, groups, slimeData)
    local instance = NPEntity:new(x, y, slimeData.width, slimeData.height, groups, slimeData.hitboxRelationX, slimeData.hitboxRelationY)

    -- attributes
    instance.speed = slimeData.speed
    
    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage("assets/entities/player.png")
    instance.sprite.grid = AnimationGrid:new(17, 25, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = 2
    instance.sprite.animationController = AnimationController:new({
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
            frameYInterval = 4
        }), 8, 2),
        walking_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2),
        walking_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 6
        }), 8, 2),
        walking_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 7
        }), 8, 2),
        walking_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 8
        }), 8, 2),
    }, "idle_down", true)
    instance.sprite.animationDirection = Direction.down

    Slime._registerGoals(instance)

    return setmetatable(instance, self)
end

-- register goals
function Slime:_registerGoals()
    -- chase_target_goal
    self:addGoal(ChaseTargetGoal:new(self))
end

-- animate
function Slime:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.animationDirection

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
    self.sprite.animationDirection = animationDirection
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