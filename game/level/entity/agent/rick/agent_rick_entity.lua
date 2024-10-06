local Animation = require "libraries.llove.animation".Animation
local AnimationController = require "libraries.llove.animation".AnimationController
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local Direction = require "libraries.llove.util".Direction
local AgentEntity = require "game.level.entity.agent.agent_entity"
local Shader = require "game.shader".Shader
local SpriteComponent = require "game.components.sprite_component"

local AgentRickEntity = setmetatable({}, AgentEntity)
AgentRickEntity.__index = AgentRickEntity

---@type AgentData
local AgentRickData = {
    name = "Rick",
    width = 34,
    height = 50,
    maxBaseHealth = 10,
    inventoryBaseSize = 5,
    sprite = {
        scale = 2,
        width = 17,
        height = 25
    },
    animations = {
        idle = {
            frameXInterval = '1-6',
            frameYInterval = 1,
            speed = 8,
        },
        walking = {
            frameXInterval = '1-6',
            frameYInterval = 2,
            speed = 8,
        },
        attacking_1 = {
            frameXInterval = '1-4',
            frameYInterval = 3,
            speed = 15,
        }
    }
}

-- constructor
function AgentRickEntity:new(level, groups)
    local instance = AgentEntity:new(level, groups, AgentRickData)

    -- animations
    instance.sprite = SpriteComponent:new(love.graphics.newImage("assets/entities/player.png"), AgentRickData.sprite.scale)
    instance.sprite.grid = AnimationGrid:new(AgentRickData.sprite.width, AgentRickData.sprite.height, instance.sprite.texture:getWidth(), instance.sprite.texture:getHeight())
    local agentAnimations = {}
    for name, config in pairs(AgentRickData.animations) do
        agentAnimations[name] = Animation:new(instance.sprite.grid:frames({
            frameXInterval = config.frameXInterval,
            frameYInterval = config.frameYInterval
        }), config.speed, AgentRickData.sprite.scale)
    end
    instance.sprite.animationController = AnimationController:new(agentAnimations, "idle", true)
    instance.sprite.direction = Direction.right
    -- shaders
    instance.sprite.shaders = {
        damage_flash = Shader:get("damage_flash")
    }

    return setmetatable(instance, self)
end

-- draw
function AgentRickEntity:draw()
    local needsToReplaceShader, oldShader = false, nil
    -- TODO: damage shader
    -- draw sprite
    self.sprite.animationController:draw(self.sprite.texture, self.rect.x, self.rect.y, nil, self.sprite.scale, self.sprite.scale)
    -- clear shader
    if needsToReplaceShader then
        love.graphics.setShader(oldShader)
    end
end

return AgentRickEntity