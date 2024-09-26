local ItemMeta = require "game.level.item.item_meta"

local Item = {}
Item.__index = Item

-- constructor
function Item:new(itemData, amount)
    local instance = {
        _meta = ItemMeta:new(itemData),
        amount = amount or 1
    }
    return setmetatable(instance, self)
end

-- display name
function Item:displayName()
    return self._meta.displayName
end

-- real name
function Item:name()
    return self._meta.name
end

-- max stack
function Item:maxStack()
    return self._meta.maxStack
end

-- sprite
function Item:sprite()
    return self._meta.sprite
end

-- item type
function Item:itemType()
    return self._meta.type
end

-- get meta
function Item:meta()
    return self._meta
end

-- set meta
function Item:setMeta(newItemMeta)
    for k, _ in pairs(self._meta) do
        self._meta[k] = nil
    end
    for k, v in pairs(newItemMeta) do
        self._meta[k] = v
    end
end

return Item