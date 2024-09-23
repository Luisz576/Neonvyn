local Sprite = require "libraries.llove.component".Sprite
local Group = require "libraries.llove.component".Group
local Rect = require "libraries.llove.component".Rect
local Vector2D = require "libraries.llove.math".Vector2D

local Entity = {}
Entity.__index = Entity

-- constructor
function Entity:new(x, y, width, height, groups)
    local instance = Sprite:new(groups)
    instance.rect = Rect:new(x, y, width, height)
    instance.velocity = Vector2D:zero()
    instance.speed = 200
    return setmetatable(instance, Entity)
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

-- move logic
function Entity:_move(dt)
    -- normalizations
    if self.velocity:magnitude() > 0 then
        self.velocity = self.velocity:normalize()
    end
    -- move in x
    self.rect.x = self.rect.x + self.velocity.x * self.speed * dt
    -- move in y
    self.rect.y = self.rect.y + self.velocity.y * self.speed * dt
end

-- collision
function Entity:_collision()
    for _, group in ipairs(Sprite.groups(self)) do
        for _, sprite in ipairs(Group.sprites(group)) do
            
        end
    end
end

-- update
function Entity:update(dt)
    -- moviment logic
    Entity._move(self, dt)
    -- collision logic
    Entity._collision(self)
end

return Entity