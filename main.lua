require "planet"
require "vec2"
require "misc"

G = 6.67*(10^-4)

function love.load()
  love.window.setMode(700, 700)

  love.physics.setMeter(1)
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  Planet(1, Vec2(100, 100), 10)
  Planet(2, Vec2(300, 300), 100)
end

function love.update(dt)
  world:update(dt)
  --for i=1, #planets do
    --planets[i]:update()
  --end
end

function love.draw()
  for i=1, #planets do
    planets[i]:draw()
  end
end
