require "planet"
require "lander"
require "vec2"

G = 6.67*(10^-3)

lg = love.graphics

function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  player1 = nil
  player2 = nil
end

function love.load()
  love.window.setMode(1000, 700)
	plSize = 1
	love.keyboard.setKeyRepeat(true)
  -- Create the two players
  player1 = nil
  player2 = nil

  autoDampening = true  -- Automatic dampening of landers.

  VEL_DEBUG = false
  FORCE_DEBUG = false
  mouseX, mouseY = 0, 0
  love.physics.setMeter(1)
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  Planet(1, Vec2(500, 350), Vec2(0, 0), 50, 100)
  Planet(2, Vec2(300, 100), Vec2(33, 0), 5, 100)

  --update_rate = 1/60
  --update_timer = 0
end

function love.mousepressed(x, y, button)
  mouseX, mouseY = x, y
end

function love.mousereleased(x, y, button)
  if button == 1 then
    Planet(#planets+1, Vec2(mouseX, mouseY), Vec2(mouseX-x, mouseY-y), plSize, 100)
  end

  if button == 2 then
		drawGridOfPlanets(mouseX, mouseY, x, y, plSize)
  end
end

function love.keypressed(key)
  if key == "c" then
    resetWorld()
  elseif key == "r" then
    resetWorld()
    Planet(1, Vec2(500, 350), Vec2(0, 0), 50, 100)
    Planet(2, Vec2(300, 100), Vec2(33, 0), 5, 100)
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
      player1 = Lander(1, mX, mY, Vec2(0, 0), 20, 20, 1)
    else
			player1:changeThrust(0.2)
    end
  end

  if key == "s" and player1 ~= nil then
		player1:changeThrust(-0.2)
  end

	-- player 2 controls
  if key == "up" then
		if player2 == nil then
			local mX, mY = love.mouse.getPosition()
      player2 = Lander(2, mX, mY, Vec2(0, 0), 20, 20, 1)
		else
			player2:changeThrust(0.2)
		end
	end	

	if key == "down" and player2 ~= nil then
		player2:changeThrust(-0.2)
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
    if love.keyboard.isDown("a") then
      player1:turnLeft()
    end
    if love.keyboard.isDown("d") then
      player1:turnRight()
    end
    player1:draw()
	else
		lg.print("Player 1 press 'w' to join.", 400, 10)
	end

	if player2 ~= nil then
		if love.keyboard.isDown("left") then
			player2:turnLeft()
		end
		if love.keyboard.isDown("right") then
			player2:turnRight()
		end
		player2:draw()
  elseif player1 ~= nil then
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
			Planet(#planets+1, Vec2(mouseX+(i*size*2), mouseY+(j*size*2)), Vec2(mouseX-x, mouseY-y), size, 100)
		end
  end
end
