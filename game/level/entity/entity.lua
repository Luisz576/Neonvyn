local Sprite = require "libraries.llove.component".Sprite
local Rect = require "libraries.llove.component".Rect
local Vector2D = require "libraries.llove.math".Vector2D
local StateMachine = require "libraries.llove.state_machine".StateMachine

local Entity = setmetatable({}, Sprite)
Entity.__index = Entity

-- constructor
function Entity:new(entityType, level, width, height, groups, collider)
    local instance = Sprite:new(groups)

    instance.level = level
    instance._spawned = false

    -- components
    instance.rect = Rect:new(0, 0, width, height)
    instance.collider = collider
    instance.stateMachine = StateMachine:new()

    -- attributes
    instance.entityType = entityType
    instance.velocity = Vector2D:zero()
    instance.speed = 200
    instance.canMove = true

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
function Entity:teleportToXY(x, y)
    self.rect.x = x
    self.rect.y = y
    -- TODO: set position
    self.collider
end
-- set position of entity
function Entity:teleportTo(pos)
    self.rect.x = pos.x
    self.rect.y = pos.y
    -- TODO: set position
    self.collider
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
    if self.collider then
        -- move
        self.collider:setLinearVelocity(self.velocity.x * self.speed, self.velocity.y * self.speed)
    else
        self.rect.x = self.rect.x + self.velocity.x * self.speed * dt
        self.rect.y = self.rect.y + self.velocity.y * self.speed * dt
    end
end

-- state
function Entity:_state(dt)
    -- state machine
    self.stateMachine:update(dt)
end

-- update components
function Entity:_updateComponents()
    if self.collider then
        -- rect update
        self.rect.x = self.collider:getX()
        self.rect.y = self.collider:getY()
    end
end

-- animate
function Entity:_animate(dt) end

-- update
function Entity:update(dt)
    -- state
    self:_state(dt)
    -- components
    self:_updateComponents()
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