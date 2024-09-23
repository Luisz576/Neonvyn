Vector2D = {}
Vector2D.__index = Vector2D

--- constructor
--- @param x number
--- @param y number
function Vector2D:new(x, y)
    local instance = {
        x = x or 0,
        y = y or 0
    }
    return setmetatable(instance, Vector2D)
end

-- explicit
function Vector2D:zero()
    return Vector2D:new(0, 0)
end

-- magnitude
function Vector2D:magnitude(x, y)
    x = x or self.x
    y = y or self.y
    return math.sqrt(x^2 + y^2)
end

-- normalize
function Vector2D:normalize(x, y)
    x = x or self.x
    y = y or self.y
    -- Calculate the magnitude
    local magnitude = Vector2D.magnitude(self)
    -- Handle the case of a zero vector
    if magnitude == 0 then
        return 0, 0
    end
    return Vector2D:new(x / magnitude, y / magnitude)
end

return Vector2D