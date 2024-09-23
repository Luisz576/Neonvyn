local sti = require 'libraries.sti'
local Player = require "game.level.entity.player"

Level = {}
Level.__index = Level

function Level:new()
    local instance = {
        player = Player:new(100, 100),
        gameMap = sti('maps/world_1.lua')
    }

    -- TODO: load level

    return setmetatable(instance, Level)
end

function Level:update(dt)
    -- player update
    self.player:update(dt)
end

function Level:draw()
    -- TODO: look better
    self.gameMap:draw(0, 0, 2, 2)
    -- player draw
    self.player:draw()
end

return Level