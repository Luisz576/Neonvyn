local ItemData = require "game.level.item.item_data".ItemData

---@enum Items
local Items = {
    APPLE = ItemData:food(
        "apple",
        "assets/items/apple.png",
        10,
        "It's an apple",
        4
    )
}

return Items