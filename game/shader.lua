local Shader = {
    _shaders = {}
}
Shader.__index = Shader

-- all shaders
local _shadersToLoad = {
    damage_flash = "game/shaders/damage_flash.glsl"
}

-- load
function Shader.load()
    -- load all shaders
    for shaderName, shaderPath in pairs(_shadersToLoad) do
        Shader.add(shaderName, shaderPath)
    end
end

-- add a shader
function Shader.add(shaderName, shaderPath)
    Shader._shaders[shaderName] = love.graphics.newShader(shaderPath)
end

-- get the shader
function Shader.get(shaderName)
    return Shader._shaders[shaderName]
end

return Shader