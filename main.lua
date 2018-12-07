
require "constants"
require "misc"
require "debug_funcs"
require "vec2"
require "planet"

function love.load()
  lw.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
	
	font = lg.newFont("fonts/unscii-8.pcf", 8)
	lg.setFont(font)
		
  planets = {}
  Planet(1, Vec2(300, 400), Vec2(0, 0), 50, 1000)
  Planet(2, Vec2(300, 100), Vec2(15, 0), 10, 2000)
  --Planet(2, Vec2(400, 500), Vec2(0, 0), 25, 10)
  --Planet(3, Vec2(400, 300), Vec2(0, 0), 25, 10)
	--Planet(4, Vec2(400, 200), Vec2(0, 0), 25, 10)
end

function love.mousepressed(x, y, button)
	if button == 1 then
		Planet(#planets+1, Vec2(x, y), Vec2(0, 0), 25, 1000)
	end
end

function love.keypressed(key)
	if key == "r" then
		le.quit("restart")
	elseif key == "escape" then
		le.quit()
	elseif
	
	key == "1" then
		DRAW_COLLISIONS = not DRAW_COLLISIONS
	elseif key == "2" then
		DRAW_MOMENTUM = not DRAW_MOMENTUM
	elseif key == "3" then
		DRAW_CONNECTIONS = not DRAW_CONNECTIONS
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
	drawDebugSettings()
end
