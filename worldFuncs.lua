function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  planets = {}
  players = {}
  bullets = {}
end

function clearBullets()
  for i=1, #bullets do
    bullets[i].body:destroy()
  end
  bullets = {}
end

function destroyBullet(i) -- index of bullet in bullet table
  bullets[i].body:destroy()
  bullets[i] = nil
  table.remove(bullets, i)
end

function checkBulletsInBounds()
  local w, h = love.graphics.getDimensions() -- In case the window changes size
  local i = 1
  while i <= #bullets do
    local x, y = bullets[i].body:getX(), bullets[i].body:getY()
    if x < 0 or x > w or y < 0 or y > h then
      destroyBullet(i)
    else
      i = i + 1
    end
  end
end
