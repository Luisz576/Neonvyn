local love = require "love"
local Direction = require "libraries.llove.util".Direction
local Animation = require "libraries.llove.animation".Animation
local AnimationController = require "libraries.llove.animation".AnimationController
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local Entity = require "game.level.entity.entity"
local EntityType = require "game.level.entity.entity_type"
-- local Hurtbox = require "game.components.hutbox"

local Player = setmetatable({}, Entity)
Player.__index = Player

-- constructor
function Player:new(x, y, groups, collisionGroups, damageHurtboxGroup)
    local scale = 2
    local instance = Entity:new(EntityType.HUMAN, x, y, 17 * scale, 25 * scale, groups, collisionGroups, 1, 1)

    -- components
    -- instance.hurtbox = Hurtbox:new(instance, x, y, 17 * scale, 25 * scale, damageHurtboxGroup, instance, "onHurtboxJoin", "onHurtboxQuit")

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
    }, "idle_down", true)
    instance.sprite.direction = Direction.down

    return setmetatable(instance, self)
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

-- onHurtbox join
-- function Player:onHurtboxJoin(sprite)
--     print("join")
-- end

-- onHurtbox quit
-- function Player:onHurtboxQuit(sprite)
--     print("quit")
-- end

-- update
function Player:update(dt)
    -- input
    self:_input()
    -- animate
    self:_animate(dt)
    -- call super
    Entity.update(self, dt)
    -- hurtbox
    -- self.hurtbox:update()
end

-- draw
function Player:draw()
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
end

return Player