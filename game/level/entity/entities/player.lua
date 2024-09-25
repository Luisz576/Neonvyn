local love = require "love"
local Direction = require "libraries.llove.util".Direction
local Animation = require "libraries.llove.animation".Animation
local AnimationController = require "libraries.llove.animation".AnimationController
local AnimationGrid = require "libraries.llove.animation".AnimationGrid
local Entity = require "game.level.entity.entity"
local EntityType = require "game.level.entity.entity_type"
local EntityClassification = require "game.level.entity.entity_classification"
local Shader = require "game.shader"
-- local Hurtbox = require "game.components.hutbox"

local Player = setmetatable({}, Entity)
Player.__index = Player

local PlayerConfiguration = {
    maxBaseHealth = 5
}

-- constructor
function Player:new(x, y, groups, collisionGroups, damageHurtboxGroup)
    local scale = 2
    local instance = Entity:new(EntityType.HUMAN, EntityClassification.PEACEFUL, x, y, 17 * scale, 25 * scale, groups, collisionGroups, 1, 1, PlayerConfiguration.maxBaseHealth)

    -- state
    instance.state = {}
    instance.state.receivingDamage = false
    instance.state.receivingDamageTime = 0.1
    instance.state.receivingDamageDelta = 0

    -- components
    -- instance.hurtbox = Hurtbox:new(instance, x, y, 17 * scale, 25 * scale, damageHurtboxGroup, instance, "onHurtboxJoin", "onHurtboxQuit")

    -- animationa
    instance.sprite = {}
    instance.sprite.spriteSheet = love.graphics.newImage("assets/entities/player.png")
    instance.sprite.grid = AnimationGrid:new(17, 25, instance.sprite.spriteSheet:getWidth(), instance.sprite.spriteSheet:getHeight())
    instance.sprite.scale = scale
    instance.sprite.animationController = AnimationController:new({
        -- idle
        idle_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 1
        }), 8, 2),
        idle_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 2
        }), 8, 2),
        idle_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 3
        }), 8, 2),
        idle_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 2
        }), 8, 2):flipX(),
        -- walking
        walking_down = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 4
        }), 8, 2),
        walking_right = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2),
        walking_up = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 6
        }), 8, 2),
        walking_left = Animation:new(instance.sprite.grid:frames({
            frameXInterval = '1-6',
            frameYInterval = 5
        }), 8, 2):flipX(),
    }, "idle_down", true)
    instance.sprite.direction = Direction.down
    -- shaders
    instance.sprite.shaders = {
        damage_flash = Shader.get("damage_flash")
    }

    return setmetatable(instance, self)
end

-- input
function Player:_input()
    -- moviment controls
    -- move in x
    self.velocity.x = (love.keyboard.isDown("d") and 1 or 0) + (love.keyboard.isDown("a") and -1 or 0)
    -- move in y
    self.velocity.y = (love.keyboard.isDown("s") and 1 or 0) + (love.keyboard.isDown("w") and -1 or 0)
end

-- animate
function Player:_animate(dt)
    local animationName = "idle"
    local animationDirection = self.sprite.direction

    -- is moving
    if self:isMoving() then
        animationName = "walking"
    end

    -- animation direction
    if self.velocity.x > 0 then
        animationDirection = Direction.right
    elseif self.velocity.x < 0 then
        animationDirection = Direction.left
    elseif self.velocity.y > 0 then
        animationDirection = Direction.down
    elseif self.velocity.y < 0 then
        animationDirection = Direction.up
    end
    -- save direction
    self.sprite.direction = animationDirection
    -- set animation
    self.sprite.animationController:change(animationName .. "_" .. animationDirection)
    -- update animation
    self.sprite.animationController:update(dt)
end

-- state manager
function Player:_state(dt)
    self.canMove = true
    -- receiving damage
    if self.state.receivingDamage then
        self.canMove = false
        self.state.receivingDamageDelta = self.state.receivingDamageDelta - dt
        -- stop receiving damage
        if self.state.receivingDamageDelta <= 0 then
            self.state.receivingDamageDelta = 0
            self.state.receivingDamage = false
            self.canMove = true
        end
    end
end

-- onHurtbox join
-- function Player:onHurtboxJoin(sprite)
--     print("join")
-- end

-- onHurtbox quit
-- function Player:onHurtboxQuit(sprite)
--     print("quit")
-- end

-- on get hurted
function Player:_onHurt(source)
    -- verification if can receive damage
    if not self.state.receivingDamage then
        -- set receiving damage state
        self.state.receivingDamage = true
        self.state.receivingDamageDelta = self.state.receivingDamageTime
        print(tostring(self.health.h) .. "/" .. tostring(self.health.mh))
        -- super
        Entity._onHurt(self, source)
    end
end

function Player:_onDie(source)
    print("DIE")
end

-- update
function Player:update(dt)
    -- input
    self:_input()
    -- state manager
    self:_state(dt)
    -- animate
    self:_animate(dt)
    -- call super
    Entity.update(self, dt)
    -- hurtbox
    -- self.hurtbox:update()
end

-- draw
function Player:draw()
    local needsToClearShader = false
    -- damage shader
    if self.state.receivingDamage then
        needsToClearShader = true
        love.graphics.setShader(self.sprite.shaders.damage_flash)
        local percentOfReceivingDamage = (self.state.receivingDamageDelta / self.state.receivingDamageTime)
        -- intensity
        self.sprite.shaders.damage_flash:send("flash_intensity", percentOfReceivingDamage)
    end
    -- draw player sprite
    self.sprite.animationController:draw(self.sprite.spriteSheet, self.rect.x, self.rect.y, nil, self.sprite.scale)
    -- clear shader
    if needsToClearShader then
        love.graphics.setShader()
    end
end

return Player