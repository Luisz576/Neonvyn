local Group = require "libraries.llove.component".Group

-- Groups
local Groups = {
    SPRITES_RENDER = "sprites_render",
    COLLISION = "collision",
    ENTITY = "entity"
}
Groups.__index = Groups

-- Sprites Render Group
local SpritesRenderGroup = setmetatable({}, Group)
SpritesRenderGroup.__index = SpritesRenderGroup

local function sortByZLayer(a, b)
    return a.z < b.z
end

-- ? probably create based on canvas?
function SpritesRenderGroup:draw()
    table.sort(self._sprites, sortByZLayer)
    for _, sprite in pairs(self._sprites) do
        sprite:draw()
    end
end

-- Builder
function Groups.newGroup(group)
    if group == Groups.SPRITES_RENDER then
        return SpritesRenderGroup:new(group)
    end
    return Group:new(group)
end

return Groups