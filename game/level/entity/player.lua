local love = require "love"
local Direction = require "libraries.llove.util".Direction
local Entity = require "game.level.entity.entity"
local Animation = require "libraries.llove.animation".Animation
local AnimationController = require "libraries.llove.animation".AnimationController
local AnimationGrid = require "libraries.llove.animation".AnimationGrid

local Player = {}
Player.__index = Player

-- constructor
function Player:new(x, y, groups)
    local instance = Entity:new(x, y, 17, 25, groups, 0.5, 0.5)

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

    return setmetatable(instance, Player)
end

-- input
function Player:_input()
    -- moviment controls
    -- move in x
    self.velocity.x = (love.keyboard.isDown("d") and 1 or 0) + (love.keyboard.isDown("a") and -1 or 0)
    -- move in y
    self.velocity.y = (love.keyboard.isDown("s") and 1 or 0) + (love.keyboard.isDown("w") and -1 or 0)
end

-- animate
function Player:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.animationDirection

    -- is moving
    if Entity.isMoving(self) then
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
end

-- update
function Player:update(dt)
    -- input
    Player._input(self)
    -- animate
    Player._animate(self, dt)
    -- update animation
    self.sprite.animationController:update(dt)
    -- call super
    Entity.update(self, dt)
end

-- draw
function Player:draw()
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
end

return Player