local Rect = require "libraries.llove.component".Rect
local tableContains = require "libraries.llove.util".tableContains
local ifTableContainsRemove = require "libraries.llove.util".ifTableContainsRemove

local Hurtbox = setmetatable({}, Rect)
Hurtbox.__index = Hurtbox

-- constructor
function Hurtbox:new(parent, x, y, width, height, groups, listener, onJoinFunctionName, onExitFunctionName)
    local instance = Rect:new(x, y, width, height)

    instance.actived = true
    instance._sprites = {}
    instance.parent = parent
    instance.groups = groups or {}
    instance.listener = listener
    instance.onJoinFunctionName = onJoinFunctionName
    instance.onExitFunctionName = onExitFunctionName

    return setmetatable(instance, self)
end

-- update
function Hurtbox:update()
    if self.actived then
        local sprites
        for _, group in pairs(self.groups) do
            sprites = group:sprites()
            for _, sprite in pairs(sprites) do
                if sprite ~= self.parent then
                    -- sprite join
                    if self:collideRect(sprite.hitbox) then
                        if not tableContains(self._sprites, sprite) then
                            -- save sprite
                            table.insert(self._sprites, sprite)
                            if self.onJoinFunctionName ~= nil then
                                self.listener[self.onJoinFunctionName](self.listener, sprite)
                            end
                        end
                    else
                        -- sprite exit
                        if ifTableContainsRemove(self._sprites, sprite) ~= nil then
                            if self.onExitFunctionName ~= nil then
                                self.listener[self.onExitFunctionName](self.listener, sprite)
                            end
                        end
                    end
                end
            end
        end
    else
        for i, sprite in pairs(self._sprites) do
            table.remove(self._sprites, i)
            if self.onExitFunctionName ~= nil then
                self.listener[self.onExitFunctionName](self.listener, sprite)
            end
        end
    end
end

return Hurtbox