local ParticlesManager = require "libraries.llove.particles".ParticlesManager
local ParticlesMeta = require "libraries.llove.particles".ParticlesMeta

local Particles = ParticlesManager:new()

-- particles to load
local _particlesToLoad = {
    -- teste = ParticlesMeta:new(
    --     "assets/particles.png",
    --     {
    --         speed = {
    --             min = 100,
    --             max = 200
    --         },
    --         spread = math.pi,
    --         particleLifeTime = {
    --             min = 0.5,
    --             max = 3
    --         },
    --         sizes = { 0.2, 0.5, 0.8, 1, 2 },
    --         emissionArea = {
    --             distribution = "uniform",
    --             width = 100,
    --             height = 100,
    --             rotation = 0
    --         }
    --     }
    -- )
}

-- load particles
local function loadParticles()
    for particlesName, particlesMeta in pairs(_particlesToLoad) do
        Particles:register(particlesName, particlesMeta)
    end
end

return {
    Particles = Particles,
    loadParticles = loadParticles
}