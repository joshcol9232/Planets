function resetWorld()
  world:destroy()
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(nil, nil, nil, postSolveCallback)
  camera.playerBody = nil
  bodies = {planets={}, players={}, bullets={}, missiles={}}
  areas = {}
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

function changeHpAfterCollisionFunc()
  local i = 1
  while i <= #changeHpAfterCollision do
    if not changeHpAfterCollision[i].bod.body:isDestroyed() then
      changeHpAfterCollision[i].bod:changeHp(changeHpAfterCollision[i].change)
      table.remove(changeHpAfterCollision, i)
    else
      i = i + 1
    end
  end
end

function mergeAfterCollision()
  local i = 1
  while i <= #plToMerge do
    print(love.timer.getTime()-plToMerge[i].time)
    if love.timer.getTime()-plToMerge[i].time >= PL_JOIN_TIME then
      print("Merging")
      mergePlanets(plToMerge[i][1], plToMerge[i][2])
      table.remove(plToMerge, i)
    else
      i = i + 1
    end
  end
  plToMerge = {}
end

function getTotalMassInWorld()
  local bods = world:getBodies()
  total = 0
  for i=1, #bods do
    total = total + bods[i]:getMass()
  end
  return total
end

function checkBulletTimeouts()  -- Needs to be separate from bullet:update due to loop in main update
  local i = 1
  while i <= #bodies.bullets do
    if bodies.bullets[i].totalTime >= BLT_TIMEOUT then
      bodies.bullets[i].body:destroy()
      table.remove(bodies.bullets, i)
    else
      i = i + 1
    end
  end
end

function checkSmallPlanetTimeouts()  -- Needs to be separate from bullet:update due to loop in main update
  local i = 1
  while i <= #bodies.planets do
    if bodies.planets[i].hasTimeout then
      if bodies.planets[i].totalTime >= bodies.planets[i].timeLimit then
        bodies.planets[i].body:destroy()
        table.remove(bodies.planets, i)
      end
    end
    i = i + 1
  end
end
