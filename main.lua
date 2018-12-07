
require "constants"
require "misc"
require "vec2"
require "planet"

function love.load()
  lw.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
		
  planets = {}
  Planet(1, Vec2(400, 200), Vec2(0, 10), 50, 100)
  Planet(2, Vec2(300, 500), Vec2(0, -10), 50, 100)
  --Planet(2, Vec2(400, 500), Vec2(0, 0), 25, 1000)
  --Planet(3, Vec2(400, 300), Vec2(0, 0), 25, 1000)
	--Planet(4, Vec2(400, 200), Vec2(0, 0), 25, 1000)
end

function love.keypressed(key)
	if key == "r" then
		le.quit("restart")
	elseif key == "escape" then
		le.quit()
	end
end

function love.update(dt)
  deltaT = dt
  for i=1, #planets do
      planets[i]:update()
  end
end

function love.draw()
  for i=1, #planets do
      planets[i]:draw()
  end
end
