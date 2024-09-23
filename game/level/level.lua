local sti = require 'libraries.sti'
local Player = require "game.level.entity.player"
local Group = require "libraries.llove.component".Group
local Groups = require "game.level.groups"

local Level = {}
Level.__index = Level

function Level:new()
    local instance = {
        gameMap = sti('maps/world_1.lua'),
        groups = {}
    }
    instance.groups.entitiesGroup = Group:new(Groups.ENTITY)
    instance.player = Player:new(100, 100, {instance.groups.entitiesGroup})

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