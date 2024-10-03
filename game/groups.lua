local Group = require "libraries.llove.component".Group

-- Groups
local Groups = {
    SPRITES_RENDER = "sprites_render",
    COLLISION = "collision",
    ENTITY = "entity",
    AGENT = "agent"
}
Groups.__index = Groups

-- Sprites Render Group
local SpritesRenderGroup = setmetatable({}, Group)
SpritesRenderGroup.__index = SpritesRenderGroup

local function sortByZLayer(a, b)
    return a.z < b.z
end

-- ? probably create based on canvas?
function SpritesRenderGroup:draw(shader)
    if shader ~= nil then
        love.graphics.setShader(shader)
    end
    table.sort(self._sprites, sortByZLayer)
    for _, sprite in pairs(self._sprites) do
        sprite:draw()
    end
    if shader ~= nil then
        love.graphics.setShader()
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