local sti = require 'libraries.sti'
local Groups = require "game.groups"
local AgentRickEntity = require "game.level.entity.agent.rick.agent_rick_entity"
local GreenSlimeEntity = require "game.level.entity.enemy.slime.green_slime_entity"
local ItemEntity = require "game.level.entity.item_entity"
local Item = require "game.level.item.item"
local Items = require "game.level.item.items"
local Shader = require "game.shader".Shader

local Level = {}
Level.__index = Level

function Level:new()
    local instance = {
        gameMap = sti('maps/world_1.lua'),
        groups = {},
        shaders = {},
        _entities = {},
    }
    -- groups
    instance.groups.spritesRender = Groups.newGroup(Groups.SPRITES_RENDER)
    instance.groups.entitiesGroup = Groups.newGroup(Groups.ENTITY)
    instance.groups.agentsGroup = Groups.newGroup(Groups.AGENT)

    return setmetatable(instance, self)
end

function Level:load()
    -- shaders
    self.shaders.sunsetShader = Shader:get("sunset")
    self.shaders.sunsetShader:send("sunset_intensity", 0.3)
    -- Agent
    AgentRickEntity:new(self, {self.groups.spritesRender, self.groups.entitiesGroup, self.groups.agentsGroup}):spawn(100, 100)
    -- spawn random slimes
    for i = 1, 10, 1 do
        GreenSlimeEntity:new(self, {self.groups.spritesRender, self.groups.entitiesGroup}, self.groups.agentsGroup):spawn(math.random(0, 600), math.random(0, 600))
    end
    for i = 1, 5, 1 do
        ItemEntity:new(Item:new(Items.APPLE, 2), self, {self.groups.spritesRender, self.groups.entitiesGroup}, self.groups.entitiesGroup):spawn(math.random(0, 600), math.random(0, 600))
    end
end

-- spawn entity
function Level:_spawnEntity(entity)
    table.insert(self._entities, entity)
end

-- remove entity
function Level:_removeEntity(entity)
    for i, e in pairs(self._entities) do
        if e == entity then
            table.remove(self._entities, i)
            return
        end
    end
end

-- update
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
    self.groups.spritesRender:draw(self.shaders.sunsetShader)
end

return Level