local Class = require "libs/hump/class"
local Anim8 = require "libs/anim8"
local Sounds = require "engine/SoundEffects" -- include the sound effects library
local Timer = require "libs/hump/timer"

--PUT THE SPRITES AND ANIMATION THINGS HERE
local duckSprite = love.graphics.newImage("sprites/regDuckSp.png")
local duckGrid = Anim8.newGrid(37, 30, duckSprite:getWidth(), duckSprite:getHeight())

local decoySprite = love.graphics.newImage("sprites/decoySpr.png")
local decoyGrid = Anim8.newGrid(38, 30,decoySprite:getWidth(), decoySprite:getHeight())

local alienSprite = love.graphics.newImage("sprites/alienSp.png")
local alienGrid = Anim8.newGrid(200,170, alienSprite:getWidth(), alienSprite:getHeight())

local alienDecoySprite = love.graphics.newImage("sprites/ufoSp.png")
local alienDecoyGrid = Anim8.newGrid(50,34, alienDecoySprite:getWidth(), alienDecoySprite:getHeight())


local Enemy = Class{}
function Enemy:init(direction, isDecoy, alien)
    self.x = gameWidth + 1 -- start the duck off screen to the right
    self.y = math.random(100,500)
    self.dead = false
    self.speed = 70
    self.ySpeed = 0
    self.direction = direction or "right"
    self.isDecoy = isDecoy or false
    self.alien = alien or false

    if not isDecoy then
        if not self.alien then
            self.state = "flying"
        else
            self.state = "flyingAlien"
        end
    else
        if not self.alien then
            self.state = "flyingDecoy"
        else
            self.state = "flyingAlienDecoy"
        end
    end

    if not self.alien then
        self.width = 37
        self.height = 30
    elseif self.state == "flyingAlien" then
        self.width = 200 * 0.3
        self.height = 170 * 0.3
    elseif self.state == "flyingAlienDecoy" then
        self.width = 50
        self.height = 34
    end

    --set the speed to be neg or pos based off fly direction
    if self.direction == "left" then
        self.x = -1
        self.speed = -self.speed
    end
     
    self.sprites = {
        flying = duckSprite,
        dead = duckSprite,
        flyingDecoy = decoySprite,
        deadDecoy = decoySprite,
        flyingAlien = alienSprite,
        flyingAlienDecoy = alienDecoySprite
    }
    self.animations = {
        flying = Anim8.newAnimation(duckGrid('1-3', 1), .5),
        dead = Anim8.newAnimation(duckGrid('1-1', 3), .5),

        flyingDecoy = Anim8.newAnimation(decoyGrid('1-3', 1), .5),
        deadDecoy = Anim8.newAnimation(decoyGrid('1-1', 3), .5),

        flyingAlien = Anim8.newAnimation(alienGrid('1-3', 1), 0.5),
        flyingAlienDecoy = Anim8.newAnimation(alienDecoyGrid('1-1', 1), 0.5)
    }
    self.tweenMan = nil
end

function Enemy:died()
    if self.dead then 
        return 
    end --if alr dead, dont do anything
    self.dead = true

    --tween to the bottom of screen
    self.tweenMan = Timer.tween(2, self,{ y = gameHeight+self.height})
    
    -- no need to check for alien here, they are the same sprite
    if not self.isDecoy then
        if not self.alien then
            self.state = "dead"
        end
    else
        if not self.alien then
            self.state = "deadDecoy"
        end
    end
end

--move the ducks left 
function Enemy:update(dt)
    if not self.dead then
        --these calcs will be negated when using a duck moving the opp dir.
        self.x = self.x - self.speed *dt
        if math.random() < 0.5 then
            self.ySpeed = math.random(70,110)
        else
            self.ySpeed = -math.random(70,110)
        end
        self.y = self.y - self.ySpeed *dt
        self.animations[self.state]:update(dt)
    end
end

function Enemy:draw()
    --ensure the proper direction for the duck
    local scaleX
    if self.direction == "left" then
        scaleX = 1
    else
        scaleX = -1
    end

    local offsetX
    if scaleX == -1 then
        offsetX = self.width
    else
        offsetX = 0
    end

    --scale the huge sprites
    if self.state == "flyingAlien" then
        scaleY = 0.3 
        scaleX = scaleX * 0.3 
        offsetX = (scaleX < 0) and self.width * 0.3 or 0
    else
        scaleY = 1
    end

    if not self.dead then
        self.animations[self.state]:draw(self.sprites[self.state],math.floor(self.x+offsetX),math.floor(self.y),0,scaleX,scaleY)
    else --duck is dead CHANGE THIS
        self.animations[self.state]:draw(self.sprites[self.state],math.floor(self.x+offsetX),math.floor(self.y),0,scaleX,scaleY)

    end
end

function Enemy:hit(cursor)

    if self.dead then return false end --check so i cant click a dead duck

    local colX = self.x+self.width >= cursor.x and cursor.x+cursor.width >= self.x
    local colY = self.y+self.height >= cursor.y and cursor.y+cursor.height >= self.y

    if colX and colY then 
        self:died()
    end
    return colX and colY

end

return Enemy