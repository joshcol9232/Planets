require "planet"
require "vec2"

G = 6.67*(10^-3)

lg = love.graphics

function love.load()
  love.window.setMode(700, 700)

  love.physics.setMeter(1)
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  Planet(1, Vec2(300, 300), Vec2(0, 0), 50, 1000)
  Planet(2, Vec2(300, 100), Vec2(200, 0), 20, 100)
  --Planet(4, Vec2(400, 100), Vec2(0, 0), 1, 100)
end

function love.update(dt)
  world:update(dt)
  for i=1, #planets do
    planets[i]:update()
  end
end

function love.draw()
  for i=1, #planets do
    planets[i]:draw()
  end
end
