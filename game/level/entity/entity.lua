local Sprite = require "libraries.llove.component.sprite"
local Vector2D = require "libraries.llove.utils.vector2d"

local Entity = {}
Entity.__index = Entity

-- constructor
function Entity:new(x, y, width, height, groups)
    local instance = Sprite:new(groups)
    instance.pos = Vector2D:new(x, y)
    instance.velocity = Vector2D:zero()
    instance.speed = 200
    instance.width = width
    instance.height = height
    return setmetatable(instance, Entity)
end

-- set position of entity
function Entity:teleportTo(x, y)
    self.pos.x = x
    self.pos.y = y
end

-- return if player is moving
function Entity:isMoving()
    return self.velocity.x ~= 0 or self.velocity.y ~= 0
end

-- move logic
function Entity:_move(dt)
    -- normalizations
    if self.velocity:magnitude() > 0 then
        self.velocity = self.velocity:normalize()
    end
    -- move in x
    self.pos.x = self.pos.x + self.velocity.x * self.speed * dt
    -- move in y
    self.pos.y = self.pos.y + self.velocity.y * self.speed * dt
end

-- update
function Entity:update(dt)
    -- moviment logic
    Entity._move(self, dt)
end

return Entity