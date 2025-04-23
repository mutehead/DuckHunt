local Class = require "libs.hump.class"

local Background = Class{}
function Background:init()
    self.image = love.graphics.newImage("sprites/backGround.jpg")
    
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    windowWidth, windowHeight = love.graphics.getDimensions()
    
    self.home = love.graphics.newImage("sprites/homeGround.png")
    self.homeWidth = self.home:getWidth()
    self.homeHeight = self.home:getHeight()

    self.alien = love.graphics.newImage("sprites/bg3.png")
    
    self.x = 0
    self.y = 0
end

function Background:draw()
    if gameState == "start" then
        love.graphics.draw(self.home,0,0,0, windowWidth/self.homeWidth, windowHeight/self.homeHeight)
    elseif gameState == "play" then
        love.graphics.draw(self.image, self.x, self.y, 0, windowWidth/self.width, windowHeight/self.height)
    elseif gameState == "alienState" then
        love.graphics.draw(self.alien, self.x, self.y, 0, windowWidth/self.width, windowHeight/self.height)
    end

end

function Background:update(dt)
-- if i dont need the background to move
    
end

return Background