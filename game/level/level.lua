local sti = require 'libraries.sti'
local Player = require "game.level.entity.entities.player"
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
    local sprites
    -- entity update
    sprites = self.groups.entitiesGroup:sprites()
    for _, entity in pairs(sprites) do
        entity:update(dt)
    end
end

function Level:draw()
    -- TODO: look better
    self.gameMap:draw(0, 0, 2, 2)
    -- draw
    local sprites
    for _, group in pairs(self.groups) do
        sprites = group:sprites()
        for _, sprite in pairs(sprites) do
            sprite:draw()
        end
    end
end

return Level