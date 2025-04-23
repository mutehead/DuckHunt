-- like Board on Jewels

local Class = require "libs.hump.class"
local Tween = require "libs.tween"

local Cursor = require "engine.Cursor"
local Explosion = require "engine.Explosion"
local Sounds = require "engine.SoundEffects"

local x1 = self.cursor.x
local y1 = self.cursor.y
local tweenShot1 = Tween.new(0.3, self.cursor, {x = x1, y = y1})

local GameEnv = Class{}


function GameEnv:init()
    self.cursor = Cursor(0,0, 32, 32, {1, 1, 1}, "sprites/crosshair.jpg")
    self.cursor:setCoords(0,0)
    self.cursor:setMatrixCoords(0,0)
    self.cursor:clear()
    self.gameState = "start"
    self.gameOver = false
    self.gameWidth = 800
    self.gameHeight = 600
end

function GameEnv:update(dt)
    if tweenGem1 ~= nil then
        local complete1 = tweenGem1:update(dt) -- return true when tween is over 
     
        if complete1 then 
            tweenGem1 = nil
      --      self:swap(mouseRow, mouseCol, self.cursor.row, self.cursor.col)
        end
    end


    for k=#self.explosions, 1, -1 do
        local explosion = self.explosions[k]
        if explosion:isActive() then
            explosion:update(dt)
        else
            table.remove(self.explosions, k)
        end
    end

    for _, e in ipairs(self.explosions) do
        e:draw()
    end    

    if self.tweenGem1 ~= nil  then
        local completed1 = self.tweenGem1:update(dt)
       -- local completed2 = self.tweenGem2:update(dt)
        if completed1 then
            self.tweenGem1 = nil
            
            local temp = self.tiles[mouseRow][mouseCol]
            self.tiles[mouseRow][mouseCol] = self.tiles[self.cursor.row][self.cursor.col]
            self.tiles[self.cursor.row][self.cursor.col] = temp
            self.cursor:clear()
            self:matches()
        end
    end

end

function GameEnv:draw()
    for k=1, #self.explosions do
        self.explosions[k]:draw()
    end
end

function GameEnv:createExplosion(x, y, type)
    local explosion = Explosion()
    explosion:setColor(1, 0.3, 0.3)
    explosion:trigger(self.cursor.x, self.cursor.y)
    table.insert(self.explosions, explosion)
end

return GameEnv