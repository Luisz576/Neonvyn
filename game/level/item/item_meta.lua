local ItemMeta = {}
ItemMeta.__index = ItemMeta

-- constructor
function ItemMeta:new(itemData)
    local instance = {
        -- normal item properties
        type = itemData.type,
        name = itemData.name,
        displayName = itemData.name,
        sprite = itemData.sprite,
        maxStack = itemData.maxStack or 1,
        description = itemData.description or "",
        -- food item properties
        food = itemData.food
    }
    return setmetatable(instance, self)
end

return ItemMeta