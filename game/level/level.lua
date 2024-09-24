local sti = require 'libraries.sti'
local Player = require "game.level.entity.entities.player"
local Slime = require "game.level.entity.entities.slime"
local Groups = require "game.groups"

local Entity = require "game.level.entity.entity"
local NPEntity = require "game.level.entity.npentity"

local Level = {}
Level.__index = Level

function Level:new()
    local instance = {
        gameMap = sti('maps/world_1.lua'),
        groups = {}
    }
    instance.groups.spritesRender = Groups.newGroup(Groups.SPRITES_RENDER)
    instance.groups.entitiesGroup = Groups.newGroup(Groups.ENTITY)
    instance.player = Player:new(100, 100, {instance.groups.spritesRender, instance.groups.entitiesGroup})

    -- TODO: load level

    Slime.Slime:new(100, 100, {instance.groups.spritesRender, instance.groups.entitiesGroup}, Slime.SlimeData.normal).target = instance.player

    return setmetatable(instance, self)
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
    -- draw sprites render group
    self.groups.spritesRender:draw()
end

return Level