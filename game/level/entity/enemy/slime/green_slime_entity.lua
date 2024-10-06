local Animation = require "libraries.llove.animation".Animation
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local AnimationController = require "libraries.llove.animation".AnimationController
local Direction = require "libraries.llove.util".Direction
local SlimeEntity = require "game.level.entity.enemy.slime.slime_entity"
local EntityClassification = require "game.level.entity.entity_classification"
local SpriteComponent = require "game.components.sprite_component"
local Shader = require "game.shader".Shader
-- states
local EnemyIdleState = require "game.level.entity.enemy.states.enemy_idle_state"
local EntityChasingState = require "game.level.entity.enemy.states.entity_chasing_state"

local GreenSlimeEntity = setmetatable({}, SlimeEntity)
GreenSlimeEntity.__index = GreenSlimeEntity

local GreenSlimeData = {
    -- SlimeData
    width = 14,
    height = 10,
    entityClassification = EntityClassification.AGGRESSIVE,
    speed = 80,
    maxHealth = 10,
    hitboxRelationX = 1,
    hitboxRelationY = 1,
    sprite = {
        scale = 2,
        spriteSheetPath = "assets/entities/slime.png",
        frameWidth = 20,
        frameHeight = 22,
        offsetX = -6,
        offsetY = -20,
    },
    animations = {
        idle = {
            frameXInterval = '1-4',
            frameYInterval = 1,
            speed = 5,
        },
        walking = {
            frameXInterval = '1-6',
            frameYInterval = 2,
            speed = 8,
        },
        attacking_1 = {
            frameXInterval = '1-7',
            frameYInterval = 3,
            speed = 10,
        }
    },
    slime = {
        delayToJump = 1
    },
    -- Green Slime Data
    viewDistance = 350,

}
GreenSlimeData.__index = GreenSlimeData

-- constructor
function GreenSlimeEntity:new(level, groups, agentsGroup)
    local instance = SlimeEntity:new(level, groups, GreenSlimeData)

    -- attributes
    instance.viewDistance = GreenSlimeData.viewDistance

    -- groups
    instance.agentsGroup = agentsGroup

    -- animations
    instance.sprite = SpriteComponent:new(love.graphics.newImage(GreenSlimeData.sprite.spriteSheetPath), GreenSlimeData.sprite.scale)
    instance.sprite.grid = AnimationGrid:new(GreenSlimeData.sprite.frameWidth, GreenSlimeData.sprite.frameHeight, instance.sprite.texture:getWidth(), instance.sprite.texture:getHeight())
    local slimeAnimations = {}
    for name, config in pairs(GreenSlimeData.animations) do
        slimeAnimations[name] = Animation:new(instance.sprite.grid:frames({
            frameXInterval = config.frameXInterval,
            frameYInterval = config.frameYInterval
        }), config.speed, GreenSlimeEntity.spriteScale)
    end
    instance.sprite.animationController = AnimationController:new(slimeAnimations, "idle", true)
    instance.sprite.direction = Direction.right
    -- sprite fix
    instance.sprite.offsetX = GreenSlimeData.sprite.offsetX or 0
    instance.sprite.offsetY = GreenSlimeData.sprite.offsetY or 0

    -- shaders
    instance.sprite.shaders['damage_flash'] = Shader:get("damage_flash")

    -- states
    GreenSlimeEntity._registerStates(instance)
    instance.stateMachine:change("idle")

    return setmetatable(instance, self)
end

-- register states
function GreenSlimeEntity:_registerStates()
    -- idle
    self.stateMachine:registerState("idle", EnemyIdleState:new(self, { min = 5, max = 10 }, self.viewDistance, self.agentsGroup, "chasing"))
    -- chase
    self.stateMachine:registerState("chasing", EntityChasingState:new(self, self.viewDistance, "idle", 20))
end

-- draw
function GreenSlimeEntity:draw()
    local needsToReplaceShader, oldShader = false, nil
    -- TODO: damage shader
    -- draw sprite
    self.sprite.animationController:draw(self.sprite.texture, self.rect.x + self.sprite.offsetX, self.rect.y + self.sprite.offsetY, nil, self.sprite.scale, self.sprite.scale)
    -- clear shader
    if needsToReplaceShader then
        love.graphics.setShader(oldShader)
    end
end

return GreenSlimeEntity