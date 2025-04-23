local Class = require "libs.hump.class"
local Push = require "libs/push"

local Cursor = Class{}

function Cursor:init(x,y,width,height, color, image)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.color = color or {1, 1, 1}
    self.image = love.graphics.newImage("sprites/cross3.png")
    self.image:setFilter("nearest", "nearest")
end

function Cursor:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, .03, .03, self.image:getWidth()/2, self.image:getHeight()/2)
end

function Cursor:setCoords(x, y)
    self.x = x
    self.y = y
end


function Cursor:update(dt)
    local mouseX, mouseY = Push:toGame(love.mouse.getPosition())
    if mouseX and mouseY then 
        self.x = mouseX - self.width / 2
        self.y = mouseY - self.height / 2

    end
end
return Cursor