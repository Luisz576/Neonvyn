local love = require "love"

---@enum ItemType
local ItemType = {
    NORMAL = "normal",
    FOOD = "food"
}

local ItemData = {}
ItemData.__index = ItemData

-- constructor
function ItemData:normal(name, sprite, maxStack, description)
    if type(sprite) == "string" then
        sprite = love.graphics.newImage(sprite)
    end
    local instance = {
        name = name,
        sprite = sprite,
        maxStack = maxStack or 1,
        description = description or "",
        type = ItemType.NORMAL
    }
    return setmetatable(instance, self)
end

-- constructor food
function ItemData:food(name, sprite, maxStack, description, food)
    local instance = ItemData:normal(name, sprite, maxStack, description)
    -- food attributes
    instance.type = ItemType.FOOD
    instance.food = food
    return instance
end

return {
    ItemData = ItemData,
    ItemType = ItemType
}