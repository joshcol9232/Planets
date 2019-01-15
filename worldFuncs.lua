function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(nil, nil, nil, postSolveCallback)
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

function getBodTable(type)
  if type == "planet" then
    return bodies.planets
  elseif type == "lander" then
     return bodies.players
  elseif type == "bullet" then
     return bodies.bullets
  elseif type == "missile" then
     return bodies.missiles
  end
end

function getBody(type, idNum)
  local arr = getBodTable(type)

  for i=1, #arr do
    if arr[i].id.num == idNum then
      return arr[i], i
    end
  end
end

function removeBody(type, idNum)
  local b, i = getBody(type, idNum)
  if b ~= nil then
    b.body:destroy()
    table.remove(getBodTable(type), i)
  end
end

function removeDeadBodies()  -- Quick, remove the evidence
  local i = 1
  while i <= #deadBodies do
    deadBodies[i]:destroy()
    table.remove(deadBodies, i)
  end
end

function getTotalMassInWorld()
  local bods = world:getBodies()
  total = 0
  for i=1, #bods do
    total = total + bods[i]:getMass()
  end
  return total
end
