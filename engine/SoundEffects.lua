local tween = require "libs/tween"
local Class = require "libs.hump.class"

local sounds = {}


sounds['playState'] = love.audio.newSource("sounds/environment.mp3", "stream")
--sounds['shotGun']
sounds['startState'] = love.audio.newSource("sounds/intro.mp3", "stream")
sounds['shot'] = love.audio.newSource("sounds/shot.mp3", "stream")
sounds['quack'] = love.audio.newSource("sounds/quack.mp3", "stream")
sounds['metal'] = love.audio.newSource("sounds/metal.mp3", "stream")
sounds['level2'] = love.audio.newSource("sounds/Alien.mp3", "stream")
--sounds['gameOver']
sounds['levelUp'] = love.audio.newSource("sounds/RetroPUp.wav", "stream")
return sounds