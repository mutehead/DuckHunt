local Globals = require "engine/Globals" -- globals
local Background = require "engine/Background" 
local Sounds = require "engine/SoundEffects" 
local Cursor = require "engine/Cursor" 
local Stats = require "engine/Stats"
local Push = require "libs/push"
local Enemy = require "engine/Enemy"
local Timer = require "libs/hump/timer"
local Tween = require "libs.tween"
local Explosion = require "engine/Explosion"

local tweenShot1 = nil
local explosions = {}

function love.load()
    
   -- explosions = {}
    love.window.setTitle("DCKWRTH") -- stting the title of the window
    love.graphics.setDefaultFilter('nearest', 'nearest') -- scaling
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    math.randomseed(os.time()) -- RNG setup for later
    
    titleFont = love.graphics.newFont(32)

    bg1 = Background("sprites/homeGround.jpg") 
    bg2 = Background("sprites/backGround.png")
    bg3 = Background("sprites/bg3.png")
    
    crosshair =  Cursor(0,0,0,0,"sprites/crosshair.jpg")
    stats = Stats()

    --some things for spawning my ducks
    duckTime = 0
    spawnInterval = 2
    ducks = {}
    levelAlien = false

   -- tween_img = GameEnv()

   for i = 1, 10 do
        table.insert(explosions, Explosion())
   end

end

-- when the game window resizes
function love.resize(w,h)
    Push:resize(w,h)
end

function getExplosion()
    for _, explosion in ipairs(explosions) do
        if not explosion:isActive() then
            return explosion
        end
    end
    local newExplosion = Explosion()
    table.insert(explosions, newExplosion)
    return newExplosion
end

-- keyboard pressing
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" then
   
        if gameState=="start" then
             gameState = "play"
        elseif gameState == "nextLevel" then
             gameState = "alienState"
             levelAlien = true
        elseif gameState == "over" then
                 gameState = "start"
                 stats:reset()
                 for i = #ducks, 1, -1 do
                     table.remove(ducks,i)
                 end
        end
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag
    end
end

function love.update(dt)
    bg1:update(dt)
    bg2:update(dt)
    bg3:update(dt)
    crosshair:update(dt)
    stats:update(dt)
    Timer.update(dt)
    --Explosion:update(dt)
    --tween_img:update(dt)

    --update my spawn countdown
    duckTime = duckTime + dt
    --time for levels!
    --for playing the first portion of game
    if gameState == "play" or gameState == "alienState" then   
        if stats.level == 2 and levelAlien == false then
            gameState = "nextLevel" 
        end

        --SPAWNING DUCKS
        if duckTime >= spawnInterval then
            --if #ducks < 10 then -- do not let more than 10 be on screen this busted everything...
                --spawn a duck
                local direction
                if math.random() < 0.5 then
                    direction = "left"
                else
                    direction = "right"
                end
                --add the duck to the table in rand direction
                --for decoys, 30 percent chance of them occurring (boolean whether n less than .3)
                    -- 0.3 / 1 will hit 30 percent of the time
                if not levelAlien then --draw ducks
                    local isDecoy = math.random() < 0.3
                    table.insert(ducks, Enemy(direction, isDecoy, false))
                    duckTime = 0
                elseif levelAlien then--draw aliens
                    local isDecoy = math.random() < 0.3
                    table.insert(ducks, Enemy(direction, isDecoy, true))
                    duckTime = 0
                end
            --end
        end
        --CHECKING FOR SHOTS
        for i = #ducks, 1, -1 do
            ducks[i]:update(dt)
            --remove any ducks that went off screen
            --take off a life too
            if ducks[i].x > gameWidth+10 or ducks[i].x < -20 then
                if not ducks[i].isDecoy then
                    table.remove(ducks,i)
                    stats.lives = stats.lives-1
                else
                    table.remove(ducks,i)
                end
            elseif ducks[i].dead and ducks[i].y > gameHeight + ducks[i].height then
                    table.remove(ducks,i)

            end
        end



        for i=#explosions,1,-1 do
            local explosions = explosions[i]
            if explosions:isActive() then
                explosions:update(dt)
            else
                table.remove(explosions,i)
            end
        end
    end
 
    if gameState == "nextLevel" then
        --clear the ducks for next level
        for i = #ducks, 1, -1 do
            table.remove(ducks,i)
        end
    end

    if button == 1 then
        if gameState == "play" or gameState == "alienState" then
            GameEnv:createExplosion(crosshair.x, crosshair.y, "shot")
            GameEnv:update(dt)
        end
    end

   -- print("Explosion count:", #explosions)
   for i = #explosions, 1, -1 do
        local explosion = explosions[i]
        if explosion:isActive() then
            explosion:update(dt)
        else
            table.remove(explosions,i)
        end
    end
    for _, explosion in ipairs(explosions) do
        explosion:update(dt)
    end
end

function checkDuckHit(x,y)
    for i = #ducks,1, -1 do
        local duck = ducks[i]
        if hitDetected(duck,x,y)then
            duck.dead = true
            stats.score = stats.score + 1

            --local explosion = getExplosion()

            if not ducks[i].isDecoy  then
              --  explosion:setColor(1, 0.5, 0) 
            --elseif not ducks[i].isDecoy  then
              --  explosion:setColor(1, 0, 0) 
            else
                local explosion = getExplosion()
                explosion:setColor(1, 0, 0) 
            end
            
            -- Trigger the explosion at duck position
            explosion:trigger(duck.x, duck.y)
            
            
            return true
        end
    end
    return
end

function love.draw()
    Push:start()
    if gameState== "start" then
       -- love.graphics.draw(background_img,0,0) -- Draw the background
       --Background:draw()-- Draw the background 
       drawStartState()
    elseif gameState == "play" then
        drawPlayState()    
        for _, explosion in ipairs(explosions) do
            explosion:draw()
        end
    elseif gameState == "over" then
        drawGameOverState()    
    elseif gameState == "nextLevel" then
        drawIntermission()
    elseif gameState == "alienState" then
        drawAlienState()
        
        
        
    end
    Push:finish()
    for _, explosion in ipairs(explosions) do
        explosion:draw()
    end


end

--checking if our ducks are clicked
function love.mousepressed(x,y,button)

    if button == 1 then 
         if gameState == "play" or gameState == "alienState" then
            Sounds['shot']:setVolume(0.3)
            Sounds['shot']:play()
            local explosion = Explosion()
            explosion:setColor(1, 0.3, 0.3)
            explosion:trigger(crosshair.x, crosshair.y)
            table.insert(explosions, explosion)

            for i, duck in ipairs(ducks) do
            --check each duck
                if duck:hit(crosshair) then
                    if duck.isDecoy then
                        Sounds['metal']:setVolume(2.5)
                        Sounds['metal']:play()
                        stats.lives = stats.lives-1
                    else
                        Sounds['quack']:play()
                        stats:addScore(1)
                    end
                end
            end
        end
    end
end

function drawStartState()
    bg1:draw()
    Sounds['startState']:setVolume(0.3)
    Sounds['startState']:play() -- Play the sound
    Sounds['startState']:setLooping(true)
    if Sounds['playState']:isPlaying() then
        Sounds['playState']:stop()
    end
    if Sounds['level2']:isPlaying() then
        Sounds['level2']:stop()
    end
    love.graphics.printf("DUCKHUNT PLUS",titleFont,10,50, gameWidth,"center")
    love.graphics.printf("Press Enter to Play or Escape to exit", 10,90, gameWidth,"center")
    love.graphics.printf("GET ME GREEN DUCKS", titleFont, 10,130, gameWidth,"center")
end

function drawPlayState()
    Sounds['playState']:setVolume(0.3)
    Sounds['playState']:play() -- Play the sound
    Sounds['playState']:setLooping(true)
    if Sounds['level2']:isPlaying() then
        Sounds['level2']:stop()
    end

    bg2:draw()
    crosshair:draw()
    stats:draw()

    for i, duck in ipairs(ducks) do
        duck:draw() --draw ducks when the game is going
    end
end

function drawAlienState()
    Sounds['level2']:setVolume(0.3)
    Sounds['level2']:play() -- Play the sound
    Sounds['level2']:setLooping(true)
    --stop playing the first level sound
    Sounds['playState']:stop()
    Sounds['startState']:stop()
    bg3:draw()
    crosshair:draw()
    stats:draw()

    for i, duck in ipairs(ducks) do
        duck:draw() --draw ducks when the game is going
    end
end

function drawIntermission()
    love.graphics.printf("NEW LEVEL!",titleFont,0,50,gameWidth,"center")
    love.graphics.printf("Press Enter to Play or Escape to exit",0,90, gameWidth,"center")
end

function drawGameOverState()
    love.graphics.printf("GameOver",titleFont,0,50,gameWidth,"center")
    love.graphics.printf("Press Enter to Play Again or Escape to exit",0,90, gameWidth,"center")
    love.graphics.printf("Ducks Shot: "..tostring(stats.totalScore), titleFont, gameWidth/2-100, 200, 200, "center")
end
