require "constants"
require "planet"
require "lander"
require "misc"
require "levels"

lg = love.graphics

function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  players = {}
end

function love.load()
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
	plSize = 1
	love.keyboard.setKeyRepeat(true)
	landerImg = lg.newImage("assets/lander.png")    -- Load lander image

  dampening = false
  VEL_DEBUG = false
  FORCE_DEBUG = false
  mouseX, mouseY = 0, 0
  love.physics.setMeter(SCALE)
  world = love.physics.newWorld(0, 0, true)
  planets, players = loadLvl(1)
  if players == nil then
    players = {}
  end
end

function love.mousepressed(x, y, button)
  mouseX, mouseY = x, y
end

function love.mousereleased(x, y, button)
  if button == 1 then
    table.insert(planets, Planet(#planets+1, mouseX, mouseY, mouseX-x, mouseY-y, plSize, PL_DENSITY))
  end

  if button == 2 then
		drawGridOfPlanets(mouseX, mouseY, x, y, plSize)
  end
end

function love.keypressed(key)
  if key == "c" then
    resetWorld()
  end

  if inTable(levelNames, key) then
		if love.keyboard.isDown("r") then
      resetWorld()
      planets, players = loadLvl(tonumber(key))
		end
  elseif key == "f" then
    FORCE_DEBUG = not FORCE_DEBUG
  elseif key == "v" then
    VEL_DEBUG = not VEL_DEBUG
	elseif key == "=" then
		plSize = plSize + 1
	elseif key == "-" and plSize > 1 then
		plSize = plSize - 1
  elseif key == "t" then
    dampening = not dampening
  end
  -- player 1 controls
  if key == "w" then
    if players[1] == nil then
      local mX, mY = love.mouse.getPosition()
       table.insert(players, Lander(1, mX, mY, 0, 0, 20, 20, LD_DENSITY))
    end
  end

	-- player 2 controls
  if key == "up" then
		if players[2] == nil then
			local mX, mY = love.mouse.getPosition()
        table.insert(players, Lander(9999999, mX, mY, 0, 0, 20, 20, LD_DENSITY))
    end
  end
end

function love.update(dt)
  world:update(dt)
  for i=1, #planets do
    planets[i]:update(dt)
  end

  for i=1, #players do
    players[i]:update(dt)
  end
end

function love.draw()
  lg.setColor({1, 1, 1})
  lg.print(love.timer.getFPS(), 10, 10)
  lg.print("Object Count: "..#planets+#players, 10, 24)

	if plSize > 0 then
		lg.print("Size: "..plSize, 10, 82)
	end

  if FORCE_DEBUG then
    lg.setColor({1, 0, 0})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("F: Force debug", 10, 40)

  if VEL_DEBUG then
    lg.setColor({0, 1, 0})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("V: Velocity debug", 10, 54)

  if dampening then
    lg.setColor({1, 1 ,1})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("T: Angular Dampeners", 10, 68)
  lg.setColor({1, 1, 1})

  for i=1, #planets do
    planets[i]:draw()
  end

  for i=1, #players do
    players[i]:draw()
  end

  if #players < 1 then
		lg.setColor({0, 1, 0})
		lg.print("Player 1 press 'w' to join.", 400, 10)
  elseif #players < 2 then
		lg.setColor({0, 1, 0})
		lg.print("Player 2 press UP to join.", 400, 10)
	end
end

function drawGridOfPlanets(mouseX, mouseY, x, y, size)
	local num = 30*(1/size)
	if num > 10 then
		num = num/2
	end

  for i=0, num do
		for j=0, num do
			table.insert(planets, Planet(#planets+1, mouseX+(i*size*2), mouseY+(j*size*2), mouseX-x, mouseY-y, size, PL_DENSITY))
		end
  end
end
