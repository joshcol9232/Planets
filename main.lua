require "planet"
require "vec2"

G = 6.67*(10^-3)

lg = love.graphics

function love.load()
  love.window.setMode(1000, 700)

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
    Planet(#planets+1, Vec2(mouseX, mouseY), Vec2(mouseX-x, mouseY-y), 50, 100)
  end

  if button == 2 then
    local size = 1
    for i=0, 5 do
      for j=0, 5 do
        Planet(#planets+1, Vec2(mouseX+(i*size*2), mouseY+(j*size*2)), Vec2(mouseX-x, mouseY-y), size, 100)
      end
    end
  end
end

function love.keypressed(key)
  if key == "c" then
    world:destroy()
    world = love.physics.newWorld(0, 0, true)
    planets = {}
  elseif key == "1" then
    FORCE_DEBUG = not FORCE_DEBUG
  elseif key == "2" then
    VEL_DEBUG = not VEL_DEBUG
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

  if FORCE_DEBUG then
    lg.setColor({1, 0, 0})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("1: Force debug", 10, 40)

  if VEL_DEBUG then
    lg.setColor({0, 1, 0})
  else
    lg.setColor({0.3, 0.3, 0.3})
  end
  lg.print("2: Velocity debug", 10, 54)



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
