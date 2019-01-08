require "planet"
require "vec2"

G = 6.67*(10^-3)

lg = love.graphics

function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  planets = {}
end

function love.load()
  love.window.setMode(1000, 700)
	plGridSize = 1
	love.keyboard.setKeyRepeat(true)

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
    Planet(#planets+1, Vec2(mouseX, mouseY), Vec2(mouseX-x, mouseY-y), 10, 100)
  end

  if button == 2 then
		drawGridOfPlanets(mouseX, mouseY, x, y, plGridSize)
  end

  if button == 3 then
	
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
		plGridSize = plGridSize + 1
	elseif key == "-" then
		plGridSize = plGridSize - 1
	end
end

function love.update(dt)
  --update_timer = update_timer + dt
  --if update_timer >= update_rate then
  for i=1, #planets do
    planets[i]:update()
  end

  world:update(dt)
    --update_timer = update_timer - update_rate
end

function love.draw()
  lg.setColor({1, 1, 1})
  lg.print(love.timer.getFPS(), 10, 10)
  lg.print("Object Count: "..#planets, 10, 24)

	if plGridSize > 0 then
		lg.print("Size: "..plGridSize, 10, 68)
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
