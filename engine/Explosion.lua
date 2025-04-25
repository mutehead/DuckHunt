local Class = require "libs.hump.class"
local imgParticles = love.graphics.newImage("graphics/particles/9.png")
local Tween = require "libs.tween"
local Timer = require "libs/hump/timer"
local Push = require "libs/push"
local Background = require "engine/Background"
local Stats = require "engine/Stats"

local Explosion = Class{}
--GunshotExplosion = {}

function Explosion:init()
    self.x, self.y = 0, 0
    self.scale = 1
    self.alpha = 1
    self.tween = nil

    self.particleSystem = love.graphics.newParticleSystem(imgParticles, 100)
    --Timer.tween(0.5, self, {scale = 2, alpha = 0}, 'in-out-quad')
    self.particleSystem:setParticleLifetime(0.5, 1) -- Particles live between 0.5 and 1 second
    self.particleSystem:setSpeed(50, 100) -- Particles have a speed between 100 and 200 units per second
end

function Explosion:setColor(r,g,b)
    self.particleSystem:setColors(r,g,b,1,r,g,b,0)
end

function Explosion:trigger(x,y, type)
    --if x and y then -- if x & y not nil, set then now
        self.x, self.y = x, y
        self.particleSystem:setPosition(x, y)
    --end
    self.particleSystem:emit(30)
    self.active = true
    self.scale = 1
    self.alpha = 1
    self.tween = Tween.new(1, self, {scale = 2, alpha = 0}, 'inOutQuad')
end

function Explosion:update(dt)
    self.particleSystem:update(dt)
    if self.tween then
        local complete = self.tween:update(dt) -- return true when tween is over 
        if complete then 
            self.tween = nil
            self.alpha = 1
            self.scale = 1
            self.active = false
        end
    end
end

function Explosion:draw()
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(self.particleSystem, 0, 0, 0, self.scale, self.scale)
    love.graphics.setColor(1, 1, 1, self.alpha)

end

function Explosion:isActive()
    return self.particleSystem:getCount() > 0
end

return Explosion
