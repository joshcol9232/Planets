
require "constants"
require "misc"
require "vec2"
require "planet"

function love.load()
    lw.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
		
    planets = {}
    Planet(1, Vec2(150, 150), Vec2(0, 0), 10, 10)
    Planet(2, Vec2(210, 150), Vec2(0, 0), 10, 25)
    Planet(3, Vec2(200, 300), Vec2(0, 0), 10, 50)
		Planet(4, Vec2(350, 100), Vec2(0, 0), 10, 15)
end

function love.keypressed(key)
	if key == "r" then
		le.quit("restart")
	elseif key == "escape" then
		le.quit()
	end
end

function love.update()
    for i=1, #planets do
        planets[i]:update()
    end
end

function love.draw()
    for i=1, #planets do
        planets[i]:draw()
    end
end
