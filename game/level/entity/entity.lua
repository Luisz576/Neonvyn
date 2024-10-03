local Sprite = require "libraries.llove.component".Sprite
local Rect = require "libraries.llove.component".Rect
local Vector2D = require "libraries.llove.math".Vector2D
local Axis = require "libraries.llove.util".Axis
local StateMachine = require "libraries.llove.state_machine".StateMachine
local Groups = require "game.groups"

local Entity = setmetatable({}, Sprite)
Entity.__index = Entity

-- constructor
function Entity:new(entityType, level, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY)
    local instance = Sprite:new(groups)

    instance.level = level
    instance._spawned = false
    instance.rect = Rect:new(0, 0, width, height)
    hitboxRelationX = hitboxRelationX or 1
    hitboxRelationY = hitboxRelationY or 1
    instance.hitbox = instance.rect:inflate(hitboxRelationX * width, hitboxRelationY * height)

    -- components
    instance.stateMachine = StateMachine:new()

    -- attributes
    instance.entityType = entityType
    instance.velocity = Vector2D:zero()
    instance.speed = 200
    instance.canMove = true

    -- groups
    instance.collisionGroups = collisionGroups or {}
    instance.entityGroup = instance:getGroup(Groups.ENTITY)

    return setmetatable(instance, self)
end

-- is spawned
function Entity:spawned()
    return self._spawned
end

-- spawn
function Entity:spawn(x, y)
    if not self._spawned then
        self.rect.x = x
        self.rect.y = y
        self.level:_spawnEntity(self)
        self._spawned = true
    end
    return self
end

-- position
function Entity:pos()
    return Vector2D:new(self.rect.x, self.rect.y)
end

-- set position of entity
function Entity:teleportTo(x, y)
    self.rect.x = x
    self.rect.y = y
end

-- return if player is moving
function Entity:isMoving()
    return self.velocity.x ~= 0 or self.velocity.y ~= 0
end

-- remove
function Entity:remove()
    if self._spawned then
        self.level:_removeEntity(self)
        self._spawned = false
    end
end

-- destroy
function Entity:destroy()
    self:remove()
    self:removeFromGroups()
end

-- move logic
function Entity:_move(dt)
    -- normalizations
    if self.velocity:magnitude() > 0 then
        self.velocity = self.velocity:normalize()
    end
    -- move in x
    self.rect.x = self.rect.x + self.velocity.x * self.speed * dt
    self.hitbox:setCenterX(self.rect:centerX())
    -- collision logic
    self:_collision(Axis.horizontal)
    -- move in y
    self.rect.y = self.rect.y + self.velocity.y * self.speed * dt
    self.hitbox:setCenterY(self.rect:centerY())
    -- collision logic
    self:_collision(Axis.vertical)
end

-- collision
function Entity:_collision(axis)
    local sprites
    for _, group in pairs(self.collisionGroups) do
        sprites = group:sprites()
        for _, sprite in pairs(sprites) do
            if sprite ~= self then
                if self.hitbox:collideRect(sprite.hitbox) then
                    if axis == Axis.horizontal then
                        if self.velocity.x > 0 then
                            self.hitbox:setRight(sprite.hitbox:left())
                        elseif self.velocity.x < 0 then
                            self.hitbox:setLeft(sprite.hitbox:right())
                        end
                        self.rect:setCenterX(self.hitbox:centerX())
                    else
                        if self.velocity.y > 0 then
                            self.hitbox:setBottom(sprite.hitbox:top())
                        elseif self.velocity.y < 0 then
                            self.hitbox:setTop(sprite.hitbox:bottom())
                        end
                        self.rect:setCenterY(self.hitbox:centerY())
                    end
                end
            end
        end
    end
end

-- state
function Entity:_state(dt)
    -- state machine
    self.stateMachine:update(dt)
end

-- animate
function Entity:_animate(dt) end

-- update
function Entity:update(dt)
    -- state
    self:_state(dt)
    -- moviment logic
    if self.canMove then
        self:_move(dt)
    end
    -- animation
    self:_animate(dt)
    -- update z
    self.z = self.rect:bottom()
end

return Entity