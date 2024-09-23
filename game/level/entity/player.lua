local love = require "love"
local anim8 = require "libraries.anim8"
local Direction = require "libraries.llove.util".Direction
local Entity = require "game.level.entity.entity"

local Player = {}
Player.__index = Player

-- constructor
function Player:new(x, y, groups)
    local instance = Entity:new(x, y, 17, 25, groups)

    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage("assets/entities/player.png")
    instance.sprite.grid = anim8.newGrid(17, 25, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = 2
    instance.sprite.animations = {
        idle = {
            down = anim8.newAnimation(instance.sprite.grid('1-6', 1), 0.2),
            right = anim8.newAnimation(instance.sprite.grid('1-6', 2), 0.2),
            up = anim8.newAnimation(instance.sprite.grid('1-6', 3), 0.2),
            left = anim8.newAnimation(instance.sprite.grid('1-6', 4), 0.2)
        },
        walking = {
            down = anim8.newAnimation(instance.sprite.grid('1-6', 5), 0.2),
            right = anim8.newAnimation(instance.sprite.grid('1-6', 6), 0.2),
            up = anim8.newAnimation(instance.sprite.grid('1-6', 7), 0.2),
            left = anim8.newAnimation(instance.sprite.grid('1-6', 8), 0.2),
        }
    }
    instance.sprite.anim = instance.sprite.animations.idle.down
    instance.sprite.anim_direction = Direction.down

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
    local animation_name = "idle"
    local animation_direction = self.sprite.anim_direction

    -- is moving
    if Entity.isMoving(self) then
        animation_name = "walking"
    end

    -- animation direction
    if self.velocity.x > 0 then
        animation_direction = Direction.right
    elseif self.velocity.x < 0 then
        animation_direction = Direction.left
    elseif self.velocity.y > 0 then
        animation_direction = Direction.down
    elseif self.velocity.y < 0 then
        animation_direction = Direction.up
    end
    -- save direction
    self.sprite.anim_direction = animation_direction

    -- set animation
    self.sprite.anim = self.sprite.animations[animation_name][animation_direction]
    -- update
    self.sprite.anim:update(dt)
end

-- update
function Player:update(dt)
    -- input
    Player._input(self)
    -- animate
    Player._animate(self, dt)
    -- call super
    Entity.update(self, dt)
end

-- draw
function Player:draw()
    self.sprite.anim:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
end

return Player