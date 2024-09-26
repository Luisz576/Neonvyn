--- @enum EntityType
local EntityType = {
    HUMAN = "human",
    SLIME = "slime",
    ITEM = "item",
}
EntityType.__index = EntityType

return EntityType