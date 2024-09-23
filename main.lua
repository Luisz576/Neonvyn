-- Libraries
_G.love = require "love"

-- Load function
function love.load()
    -- imports
    local Level = require "game.level.level"

    -- prevent blurring when scale pixel
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- create the level
    _G.level = Level:new()
end

-- Update function
function love.update(dt)
    level:update(dt)
end

-- Draw function
function love.draw()
    level:draw()
end