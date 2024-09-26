---@diagnostic disable: param-type-mismatch

local AbstractInventory = {}
AbstractInventory.__index = AbstractInventory

---@class InventoryItem
---@field amount number
---@field maxStack number | function
---@field name string | function

-- empty
local EMPTY = {}

-- new slot
local function newSlot()
    return {
        item = EMPTY
    }
end

-- update slots size
local function _updateSlotsSize(_slots, oldSize, newSize)
    if oldSize == newSize then
        return _slots
    end
    local slots = {}
    if oldSize < newSize then
        -- copy slots and create new ones
        for i = 1, newSize, 1 do
            if i <= oldSize then
                slots[i] = _slots[i]
            else
                slots[i] = newSlot()
            end
        end
    else
        local s = 1
        -- copy slots with items while possible
        for i = 1, oldSize, 1 do
            if s > newSize then
                break
            end
            if _slots[i].item ~= EMPTY then
                slots[s] = _slots[i]
                s = s + 1
            end
        end
        -- create new slots
        while s <= newSize do
            slots[s] = newSlot()
            s = s + 1
        end
    end
    return slots
end

-- constructor
function AbstractInventory:new(size, name)
    local instance = {
        __len = function (inv)
            return inv._size
        end,
        _size = size,
        name = name or ""
    }
    self._slots = _updateSlotsSize({}, 0, size)
    return setmetatable(instance, self)
end

-- change size
function AbstractInventory:changeSize(newSize)
    if newSize < 1 then
        error("Invalid Inventory Size!")
    end
    self._slots = _updateSlotsSize(self._slots, self._size, newSize)
    self._size = newSize
end

-- size
function AbstractInventory:size()
    return self._size
end

-- add
---@param item InventoryItem
---@return integer -- success if 0
function AbstractInventory:add(item)
    local itemName
    local remaining = item.amount
    local index, invSize = 1, self._size
    if type(item.name) == "function" then
        itemName = item:name()
    else
        itemName = item.name
    end
    --
    local slotItemName, slotItemAmount, maxSlotItemStack
    while remaining > 0 and index <= invSize do
        if type(self._slots[index].item.name) == "function" then
            slotItemName = self._slots[index].item:name()
        else
            slotItemName = self._slots[index].item.name
        end
        if type(self._slots[index].item.maxStack) == "function" then
            maxSlotItemStack = self._slots[index].item:maxStack()
        else
            maxSlotItemStack = self._slots[index].item.maxStack
        end
        slotItemAmount = self._slots[index].item.amount
        -- TODO: fix -> when have 2 slots of same item but separed by more than 1 slot it just create other one
        -- has item
        if self._slots[index].item ~= EMPTY then
            -- is same item
            if slotItemName == itemName then
                local amountToAdd = math.min(maxSlotItemStack - slotItemAmount, remaining)
                self._slots[index].item.amount = self._slots[index].item.amount + amountToAdd
                remaining = remaining - amountToAdd
            end
        -- hasn't item
        else
            self._slots[index].item = item
            remaining = 0
        end
        index = index + 1
    end
    return remaining
end

-- add at
---@param item InventoryItem
---@param index integer
---@return integer -- success if 0
function AbstractInventory:addAt(item, index)
    local remaining = item.amount
    if index <= self._size then
        local itemName, maxSlotItemStack
        if type(self._slots[index].item.name) == "function" then
            itemName = self._slots[index].item:name()
        else
            itemName = self._slots[index].item.name
        end
        -- has item
        if self._slots[index].item ~= EMPTY then
            local slotItemName
            if type(self._slots[index].item.name) == "function" then
                slotItemName = self._slots[index].item:name()
            else
                slotItemName = self._slots[index].item.name
            end
            if type(self._slots[index].item.maxStack) == "function" then
                maxSlotItemStack = self._slots[index].item:maxStack()
            else
                maxSlotItemStack = self._slots[index].item.maxStack
            end
            -- is same item
            if slotItemName == itemName then
                local amountToAdd = math.min(maxSlotItemStack - self._slots[index].item.amount, remaining)
                self._slots[index].item.amount = self._slots[index].item.amount + amountToAdd
                remaining = remaining - amountToAdd
            end
        -- hasn't item
        else
            self._slots[index].item = item
            remaining = 0
        end
    end
    return remaining
end

-- contains
---@param item { name: string | function } | string
---@return boolean
function AbstractInventory:contains(item)
    if type(item) ~= "string" then
        if type(item.name) == "function" then
            item = item:name()
        else
            item = item.name
        end
    end
    --
    local itemSlotName
    for _, t in pairs(self._slots) do
        if t.item ~= EMPTY then
            if type(t.item.name) == "function" then
                itemSlotName = t.item:name()
            else
                itemSlotName = t.item.name
            end
            if itemSlotName == item then
                return true
            end
        end
    end
    return false
end

-- get
---@param index integer
---@return InventoryItem | nil
function AbstractInventory:get(index)
    if index > self._size then
        return nil
    end
    if self._slots[index].item ~= EMPTY then
        return self._slots[index].item
    end
    return nil
end

-- returns the index of the first occurrency of item
---@param item { name: string | function } | string
function AbstractInventory:getIndexOfItem(item)
    if type(item) ~= "string" then
        if type(item.name) == "function" then
            item = item:name()
        else
            item = item.name
        end
    end
    --
    local itemSlotName
    for k, t in pairs(self._slots) do
        if t.item ~= EMPTY then
            if type(t.item.name) == "function" then
                itemSlotName = t.item:name()
            else
                itemSlotName = t.item.name
            end
            if itemSlotName == item then
                return k
            end
        end
    end
    return nil
end

-- remove
---@param item { name: string | function } | string
---@param amount integer
---@return integer
function AbstractInventory:remove(item, amount)
    local remaining = amount
    if type(item) ~= "string" then
        if type(item.name) == "function" then
            item = item:name()
        else
            item = item.name
        end
    end
    local itemSlotName
    for k, t in pairs(self._slots) do
        if t.item ~= EMPTY then
            if type(t.item.name) == "function" then
                itemSlotName = t.item:name()
            else
                itemSlotName = t.item.name
            end
            if itemSlotName == item then
                remaining = self:removeAt(k, remaining)
                if remaining <= 0 then
                    break
                end
            end
        end
    end
    return remaining
end

-- remove at position
---@param index any
---@param amount integer
---@return integer
function AbstractInventory:removeAt(index, amount)
    if index > self._size then
        return amount
    end
    if self._slots[index].item ~= EMPTY then
        local amountToRemove = math.min(amount, self._slots[index].item.amount)
        self._slots[index].item.amount = self._slots[index].item.amount - amountToRemove
        if self._slots[index].item.amount <= 0 then
            self._slots[index].item = EMPTY
        end
        return amount - amountToRemove
    end
    return amount
end

return AbstractInventory