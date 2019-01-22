function getSplitVelocities(num)
  local vels = {}
  for i=1, math.ceil(num/2) do
    local totalV = math.random(50, PL_SPLIT_SPEED)
    local angle = math.random()*math.pi*2 -- Gets number between 0 and 1, then multiplies that by 2pi
    local dx, dy = totalV*math.cos(angle), totalV*math.sin(angle)
    table.insert(vels, {x=dx, y=dy})
  end
  for i=1, #vels do
    table.insert(vels, {x=-vels[i].x, y=-vels[i].y})  -- To conserve momentum, half need to have opposite velocity
  end
  return vels
end

function getNewR(r1, r2)
  -- Box2D uses area instead of volume.
  local totalV = (math.pi*(r1^2)) + (math.pi*(r2^2))
  return math.sqrt(totalV/math.pi)
end

function getNewPos(x1,y1, x2,y2, m1, m2, mT)
  x1 = x1*m1
  y1 = y1*m1

  x2 = x2*m2
  y2 = y2*m2
  return ((x1+x2)/2)/mT*2, ((y1+y2)/2)/mT*2  -- Just returns mean of velocity. Both should be travelling nearly the same speed anyway.
end

function mergePlanets(pl1, pl2)
  local newR = getNewR(pl1.r, pl2.r)

  local x1, y1 = pl1.body:getPosition()
  local x2, y2 = pl2.body:getPosition()

  local vx1, vy1 = pl1.body:getLinearVelocity()
  local vx2, vy2 = pl2.body:getLinearVelocity()
  local totalV1 = vx1+vy1
  local totalV2 = vx2+vy2

  local newVx = 0
  local newVy = 0
  if math.abs(totalV1) > math.abs(totalV2) then
    newVx = vx1
    newVy = vy1
  else
    newVx = vx2
    newVy = vy2
  end


  local mass1, mass2 = pl1.body:getMass(), pl2.body:getMass()
  local totalMass = mass1 + mass2
  local newX, newY = getNewPos(x1,y1, x2,y2, mass1, mass2, totalMass)

  removeBody("planet", pl1.id.num)
  removeBody("planet", pl2.id.num)

  table.insert(bodies.planets, Planet({type="p", num=#bodies.planets+1}, newX, newY, newVx, newVy, newR, PL_DENSITY))
end
