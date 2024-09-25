local ShaderManager = require "libraries.llove.shader"

local Shader = ShaderManager:new()

-- all shaders
local _shadersToLoad = {
    damage_flash = "game/shader/damage_flash.glsl"
}

-- load
local function loadShaders()
    -- load all shaders
    for shaderName, shaderPath in pairs(_shadersToLoad) do
        Shader:add(shaderName, shaderPath)
    end
end

return {
    Shader = Shader,
    loadShaders = loadShaders
}