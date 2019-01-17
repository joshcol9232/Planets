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

function checkSmallObjectsInBounds()
  local blt = bodies.bullets
  local plt = bodies.planets

  if #plt > 0 then
    local i = 1
    while i <= #plt do
      if plt[i].body:isDestroyed() then
        table.remove(plt, i)
      else
        local x, y = plt[i].body:getX(), plt[i].body:getY()
        if (plt[i].r < 3) and (x < -MAP_WIDTH or x > MAP_WIDTH or y < -MAP_HEIGHT or y > MAP_HEIGHT) then
          plt[i].body:destroy()
          table.remove(plt, i)
        else
          i = i + 1
        end
      end
    end
  end

  if #blt > 0 then
    local i = 1
    while i <= #blt do
      local x, y = blt[i].body:getX(), blt[i].body:getY()
      if x <-MAP_WIDTH or x > MAP_WIDTH or y < -MAP_HEIGHT or y > MAP_HEIGHT then
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

function getBody(type, idNum, table)
  if table == nil then
    table = getBodTable(type)
  end

  for i=1, #table do
    if table[i].id.num == idNum then
      return table[i], i
    end
  end
end

function removeBody(type, idNum)
  tabl = getBodTable(type)
  local b, i = getBody(type, idNum, tabl)
  if b ~= nil then
    b.body:destroy()
    --print("Len before:", #bodies.bullets)
    table.remove(tabl, i)
    --print("Removed body at:", i, "id:", b.id.num, "Len bodies:", #bodies.bullets)
  end
end

function removeDeadBodies()  -- Quick, remove the evidence
  local i = 1
  while i <= #deadBodies do
    deadBodies[i]:destroy()
    table.remove(deadBodies, i)
  end
end

function changeHpAfterCollisionFunc()
  local i = 1
  while i <= #changeHpAfterCollision do
    if changeHpAfterCollision[i].bod:changeHp(changeHpAfterCollision[i].change) and (not changeHpAfterCollision[i].bod.body:isDestroyed()) then--and currTime - timeOfLastPlDestruction > PL_DESTROY_RATE then
      changeHpAfterCollision[i].bod:destroy()
      table.remove(changeHpAfterCollision, i)
      --timeOfLastPlDestruction = currTime
    else
      table.remove(changeHpAfterCollision, i)
    end
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

function checkBulletTimeouts()
  local i = 1
  while i <= #bodies.bullets do
    if not bodies.bullets[i]:checkTimeout() then
      i = i + 1
    end
  end
end
