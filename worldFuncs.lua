function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  bodies = {planets={}, players={}, bullets={}, missiles={}}
end

function clearBullets()
  for i=1, #bodies.bullets do
    bodies.bullets[i].body:destroy()
  end
  bodies.bullets = {}
end

function destroyBullet(i) -- index of bullet in bullet table
  bodies.bullets[i].body:destroy()
  table.remove(bodies.bullets, i)
end

function checkBulletsInBounds()
  if #bodies.bullets > 0 then
    local w, h = love.graphics.getDimensions() -- In case the window changes size
    local i = 1
    while i <= #bodies.bullets do
      local x, y = bodies.bullets[i].body:getX(), bodies.bullets[i].body:getY()
      if x < 0 or x > w or y < 0 or y > h then
        destroyBullet(i)
      else
        i = i + 1
      end
    end
  end
end
