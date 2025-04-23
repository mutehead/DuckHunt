local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween"
local Sounds = require "engine.SoundEffects"
local statFont = love.graphics.newFont(26)

local Stats = Class{}
function Stats:init()
    self.y = 10 --tweening
    self.tweenLevel = false
    self.level = 1
    self.totalScore = 0
    self.targetScore = 3 -- for level update
    self.maxSecs = 99
    self.elapsedTime = 0
    self.timeOut = false
    self.lives = 3
end

function Stats:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Level: " ..tostring(self.level), statFont, gameWidth/2-30,10,100,"center") -- put level in middle top of screen
    love.graphics.printf("Time: " ..math.floor(tostring(self.elapsedTime)).."/"..tostring(self.maxSecs), statFont,10,10,200)
    love.graphics.printf("Ducks Shot: "..tostring(self.totalScore), statFont,gameWidth-210,10,200,"right")
    love.graphics.printf("Lives: "..tostring(self.lives), statFont,gameWidth-210,40,200,"right")

    if self.tweenLevel then
        love.graphics.setColor(1,0,1)  --Magenta
        love.graphics.printf("Level UP!", statFont, gameWidth/2-60, self.y+100,100, "center")
        love.graphics.setColor(1,1,1) -- White
    end

end


function Stats:update(dt)
    self.elapsedTime = self.elapsedTime+dt
    if self.elapsedTime > 99 then
        gameState = "over"
        self.elapsedTime = 0
        self.lives = 3
        self.level = 1
    end

    if self.lives == 0 then
        gameState = "over"
        self.elapsedTime = 0
        self.lives = 3
        self.level = 1
    end

    if self.elapsedTime > 2 and self.tweenLevel then
        self.tweenLevel = false
        self.elapsedSecs = 10
    end

    if self.tweenLevel then
        self.tweenMan:update(dt)
    end
end

function Stats:addScore(n)
    self.totalScore = self.totalScore + n
    if self.totalScore >= self.targetScore then
        self:levelUp()
        self.elapsedTime = 0
    end
end


function Stats:levelUp()
    self.level = self.level+1
    self.targetScore = self.targetScore+self.level*2
    self.elapsedTime = 0

    self.tweenLevel = true
    self.tweenMan = Tween.new(5, self, {y = self.y + 100})
    love.graphics.setColor(1,0,1)  --Magenta
   -- love.graphics.printf("Level UP!", statFont, gameWidth/2-60, self.y+100,100, "center")
   -- love.graphics.setColor(1,1,1) -- White
    Sounds.levelUp:play()
end

function Stats:reset()
    self.elapsedTime = 0
    self.lives = 3
    self.level = 1
    self.totalScore = 0
end

return Stats