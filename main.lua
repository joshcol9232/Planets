
require "misc"
require "vec2"
require "planet"

function love.load()
	love.window.setMode(400, 400)
	
	planets = {}
	Planet(1, Vec2(100, 100), Vec2(0, 1), 10, 25)
	Planet(2, Vec2(300, 300), Vec2(0, -1), 10, 25)
	Planet(3, Vec2(350, 200), Vec2(0, 0), 10, 25)
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