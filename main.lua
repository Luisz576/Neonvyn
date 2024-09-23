-- Libraries
_G.love = require "love"

-- Load function
function love.load()
    -- imports
    local Player = require "game.player"

    -- prevent blurring when scale pixel
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- create the player
    _G.player = Player:new(100, 100)
end

-- Update function
function love.update(dt)
    player:update(dt)
end

-- Draw function
function love.draw()
    player:draw()
end