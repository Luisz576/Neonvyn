local Sprite = require "libraries.llove.component".Sprite
local Rect = require "libraries.llove.component".Rect
local Vector2D = require "libraries.llove.math".Vector2D
local Axis = require "libraries.llove.util".Axis
local Groups = require "game.groups"
local Health = require "game.components.health"

local Entity = setmetatable({}, Sprite)
Entity.__index = Entity

-- constructor
function Entity:new(entityType, entityClassification, x, y, width, height, groups, collisionGroups, hitboxRelationX, hitboxRelationY, maxHealth)
    local instance = Sprite:new(groups)

    instance.rect = Rect:new(x, y, width, height)
    hitboxRelationX = hitboxRelationX or 1
    hitboxRelationY = hitboxRelationY or 1
    instance.hitbox = instance.rect:inflate(hitboxRelationX * width, hitboxRelationY * height)

    -- attributes
    instance.entityType = entityType
    instance.entityClassification = entityClassification
    instance.velocity = Vector2D:zero()
    instance.speed = 200
    instance.canMove = true

    -- components
    instance.health = Health:new(instance, maxHealth)
    instance.health:addListener(instance, "_onHeal", "_onHurt")

    -- groups
    instance.collisionGroups = collisionGroups or {}
    instance.entityGroup = instance:getGroup(Groups.ENTITY)

    return setmetatable(instance, self)
end

-- current health
function Entity:getHealth()
    return self.health.h
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

-- update
function Entity:update(dt)
    -- update z
    self.z = self.rect:bottom()
    -- moviment logic
    if self.canMove then
        self:_move(dt)
    end
end

-- on die
function Entity:_onDie(source) end

-- on get healed
function Entity:_onHeal(source) end
-- on get hurted
function Entity:_onHurt(source)
    if self.health.h <= 0 then
        self:_onDie(source)
    end
end

return Entity