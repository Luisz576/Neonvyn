local SpriteComponent = {}
SpriteComponent.__index = SpriteComponent

---@class SpriteComponent
---@field texture any
---@field scale number
---@field grid any
---@field flippedX boolean
---@field flippedY boolean
---@field offsetX number
---@field offsetY number
---@field direction any
---@field animationController any
---@field shaders table

-- constructor
---@return SpriteComponent
function SpriteComponent:new(texture, scale)
    local instance = {
        texture = texture,
        scale = scale or 1,
        grid = nil,
        direction = nil,
        animationController = nil,
        shaders = {},
        flippedX = false,
        flippedY = false,
        offsetX = 0,
        offsetY = 0
    }
    return setmetatable(instance, self)
end

return SpriteComponent