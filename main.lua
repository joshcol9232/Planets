require "planet"
require "lander"
require "misc"
require "levels"

G = 6.67*(10^-5)

lg = love.graphics
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700


function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  player1 = nil
  player2 = nil
end

function love.load()
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
	plSize = 1
	love.keyboard.setKeyRepeat(true)
  -- Create the two players
  player1 = nil
  player2 = nil

	landerImg = lg.newImage("assets/lander.png")    -- Load lander image

  VEL_DEBUG = false
  FORCE_DEBUG = false
  mouseX, mouseY = 0, 0
  love.physics.setMeter(1)
  world = love.physics.newWorld(0, 0, true)
  planets, player1, player2 = loadLvl(1)
  print(planets[0])


  --update_rate = 1/60
  --update_timer = 0
end

function love.mousepressed(x, y, button)
  mouseX, mouseY = x, y
end

function love.mousereleased(x, y, button)
  if button == 1 then
    Planet(#planets+1, mouseX, mouseY, mouseX-x, mouseY-y, plSize, PL_DENSITY)
  end

  if button == 2 then
		drawGridOfPlanets(mouseX, mouseY, x, y, plSize)
  end
end

function love.keypressed(key)
  if key == "c" then
    resetWorld()
  end

  if inTable(levels, key) then
		if love.keyboard.isDown("l") then
      resetWorld()
      if key == "1" then

      elseif key == "2" then
      elseif key == "3" then

      end
		end
  elseif key == "f" then
    FORCE_DEBUG = not FORCE_DEBUG
  elseif key == "v" then
    VEL_DEBUG = not VEL_DEBUG
	elseif key == "=" then
		plSize = plSize + 1
	elseif key == "-" and plSize > 1 then
		plSize = plSize - 1
  end

  -- player 1 controls
  if key == "w" then
    if player1 == nil then
      local mX, mY = love.mouse.getPosition()
      player1 = Lander(1, mX, mY, 0, 0, 20, 20, LD_DENSITY)
    end
  end

	-- player 2 controls
  if key == "up" then
		if player2 == nil then
			local mX, mY = love.mouse.getPosition()
      player2 = Lander(2, mX, mY, 0, 0, 20, 20, LD_DENSITY)
    end
  end
end

function love.update(dt)
  --update_timer = update_timer + dt
  --if update_timer >= update_rate then
  for i=1, #planets do
    planets[i]:update()
  end

  if player1 ~= nil then
    player1:update()
  end

  if player2 ~= nil then
    player2:update()
  end

  world:update(dt)
    --update_timer = update_timer - update_rate
end

function love.draw()
  lg.setColor({1, 1, 1})
  lg.print(love.timer.getFPS(), 10, 10)
  lg.print("Object Count: "..#planets, 10, 24)

	if plSize > 0 then
		lg.print("Size: "..plSize, 10, 68)
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

  for i=1, #planets do
    planets[i]:draw()
    if VEL_DEBUG then
      planets[i]:debugVel()
    end
    if FORCE_DEBUG then
      planets[i]:debugForce()
    end
  end

  if player1 ~= nil then
    player1:draw()
	else
		lg.setColor({0, 1, 0})
		lg.print("Player 1 press 'w' to join.", 400, 10)
	end

	if player2 ~= nil then
		player2:draw()
  elseif player1 ~= nil then
		lg.setColor({0, 1, 0})
		lg.print("Player 2 press UP to join.", 400, 10)
	end

  if player2 ~= nil then
    player2:draw()
  end
end

function drawGridOfPlanets(mouseX, mouseY, x, y, size)
	local num = 30*(1/size)
	if num > 10 then
		num = num/2
	end

  for i=0, num do
		for j=0, num do
			Planet(#planets+1, mouseX+(i*size*2), mouseY+(j*size*2), mouseX-x, mouseY-y, size, PL_DENSITY)
		end
  end
end
