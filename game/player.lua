local love = require "love"
local Entity = require "game.entity"

local Player = {}
Player.__index = Player

-- constructor
function Player:new(x, y)
    local instance = Entity:new(x, y, 100, 100)
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

-- update
function Player:update(dt)
    -- input
    self:_input()
    -- call super
    Entity.update(self, dt)
end

-- draw
function Player:draw()
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.sprite.width, self.sprite.height)
end

return Player