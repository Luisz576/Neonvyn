local AbstractInventory = require "game.level.inventory.abstract_inventory"

local Inventory = setmetatable({}, AbstractInventory)
Inventory.__index = Inventory

-- constructor
function Inventory:new(size, name)
    local instance = AbstractInventory:new(size, name)
    return setmetatable(instance, self)
end

-- ? open ui
-- ? is ui oppen
-- ? close ui

return Inventory