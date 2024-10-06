local pointsDis = require "libraries.llove.math".pointsDis
local effectFunction = require "libraries.llove.easing".Easings.EaseInCubic
local Entity = require "game.level.entity.entity"
local EntityType = require "game.level.entity.entity_type"
local EntityChasingState = require "game.level.entity.enemy.states.entity_chasing_state"

local ItemEntity = setmetatable({}, Entity)
ItemEntity.__index = ItemEntity

-- constructor
function ItemEntity:new(item, level, groups, catcherGroup)
    local instance = Entity:new(EntityType.ITEM, level, 16, 16, groups)
    -- item
    instance.item = item
    -- catch
    instance.catcherGroup = catcherGroup or {
        sprites = function () return {} end
    }
    instance.distanceToChangeDirectionWhenBeenAttracted = 10
    instance.catchMethod = "pickupItem"
    -- ? it should be moved to player or entity that can 'pickupItem' to be applied effects on it's attraction by items
    instance.attractableDistance = 50
    -- sprite
    instance.scale = 1
    return setmetatable(instance, self)
end

-- update
function ItemEntity:update(dt)
    -- reset velocity
    self.velocity.x = 0
    self.velocity.y = 0
    -- attraction logic
    local sprites = self.catcherGroup:sprites()
    for _, sprite in pairs(sprites) do
        if sprite.pickupItem ~= nil then
            -- TODO: create State
            -- TODO: don't be attracted if sprite can't get items right now (because of full inventory, etc...)
            local spriteCenter, selfCenter = sprite.rect:center(), self.rect:center()
            local dis = pointsDis(selfCenter, spriteCenter)
            if dis < self.attractableDistance then
                if dis < 10 then
                    local amountThatCouldntBePickedUp = sprite:pickupItem(self.item)
                    if amountThatCouldntBePickedUp < 1 then
                        self:destroy()
                    else
                        self.item.amount = amountThatCouldntBePickedUp
                    end
                    return
                end
                -- attract
                local disX, disY = selfCenter.x - spriteCenter.x, selfCenter.y - spriteCenter.y
                EntityChasingState._chase(self, selfCenter.x, spriteCenter.x, selfCenter.y, spriteCenter.y, math.abs(disX), math.abs(disY), self.distanceToChangeDirectionWhenBeenAttracted)
                -- effect of been attracted
                local progress = 1 - effectFunction.ratio(dis, self.attractableDistance)
                local effectFunctionRes = effectFunction.f(progress)
                self.velocity.x = self.velocity.x * dt * effectFunctionRes
                self.velocity.y = self.velocity.y * dt * effectFunctionRes
                break
            end
        end
    end
    -- super
    Entity.update(self, dt)
end

-- draw
function ItemEntity:draw()
    love.graphics.draw(self.item:sprite(), self.rect.x, self.rect.y, nil, self.scale)
end

return ItemEntity