-- Libraries
_G.love = require "love"
local Shader = require "game.shader"
local Level = require "game.level.level"
local Math = require "libraries.llove.math"

-- Load function
function love.load()
    -- prevent blurring when scale pixel
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- load shaders
    Shader.load()

    -- create the level
    _G.level = Level:new()
end

-- Update function
function love.update(dt)
    -- level update
    level:update(dt)
    -- show fps
    -- print(Math.ffps(dt))
end

-- Draw function
function love.draw()
    -- level draw
    level:draw()
end