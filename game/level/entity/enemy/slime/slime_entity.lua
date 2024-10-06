local Direction = require "libraries.llove.util".Direction
local LivingEntity = require "game.level.entity.living_entity"
local EntityType = require "game.level.entity.entity_type"

local SlimeEntity = setmetatable({}, LivingEntity)
SlimeEntity.__index = SlimeEntity

---@class SlimeData
---@field width number
---@field height number
---@field entityClassification EntityClassification
---@field speed number
---@field maxHealth number
---@field hitboxRelationX number
---@field hitboxRelationY number
---@field slime { delayToJump: number }
---@field sprite { scale: number }

-- constructor
---@param slimeData SlimeData
function SlimeEntity:new(level, groups, slimeData)
    local instance = LivingEntity:new(EntityType.SLIME, slimeData.entityClassification, level, slimeData.width * slimeData.sprite.scale, slimeData.height * slimeData.sprite.scale, groups, slimeData.maxHealth)

    -- slime attributes
    instance.slime = {}
    instance.slime.delayToJump = slimeData.slime.delayToJump
    instance.slime.deltaMove = 0.01

    -- attributes
    instance.speed = slimeData.speed

    return setmetatable(instance, self)
end

-- animate
function SlimeEntity:_animate(dt)
    local animationName = "idle"

    -- is moving
    if self:isMoving() then
        animationName = "walking"
    end

    -- is attacking
    if self.attacking then
        animationName = "attacking_1"
    end

    -- animation direction
    local animationDirection = self.sprite.direction
    if self.velocity.x > 0 then
        animationDirection = Direction.right
    elseif self.velocity.x < 0 then
        animationDirection = Direction.left
    end
    self.sprite.direction = animationDirection
    
    -- set animation
    self.sprite.animationController:change(animationName)
    self.sprite.animationController:animation().flippedX = (animationDirection == Direction.left)
    -- update animation
    self.sprite.animationController:update(dt)
end

-- slime behaviour
function SlimeEntity:_slimeBehaviour(dt)
    -- jump delay
    if not self.velocity:isZero() then
        if self.slime.deltaMove > 0 then
            self.slime.deltaMove = self.slime.deltaMove - dt
            if self.slime.deltaMove > 0 then
                self.velocity:set(0, 0)
            end
        else
            if self.sprite.animationController:animation():remainingFrames() == 0 then
                self.slime.deltaMove = math.random(self.slime.delayToJump / 2 , self.slime.delayToJump)
            end
        end
    end
end

-- state manager
function SlimeEntity:_state(dt)
    self.canMove = true
    -- super
    LivingEntity._state(self, dt)
    -- receivingDamage
    self:_slimeBehaviour(dt)
end

return SlimeEntity