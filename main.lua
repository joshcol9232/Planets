require "planet"
require "vec2"

G = 6.67*(10^-3)

lg = love.graphics

function love.load()
  love.window.setMode(1000, 700)

  love.physics.setMeter(1)
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  Planet(1, Vec2(500, 350), Vec2(0, 0), 50, 100)
  Planet(2, Vec2(300, 100), Vec2(33, 0), 5, 100)

  --update_rate = 1/60
  --update_timer = 0
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
  lg.print(love.timer.getFPS(), 10, 10)
  for i=1, #planets do
    planets[i]:draw()
  end
end
