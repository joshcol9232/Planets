require "constants"
require "debugFuncs"
require "misc"

function Missile(x, y, vel, w, h, d, rotation, parentVelX, parentVelY, target, homing)
  local m = {}
  m.w     = w
  m.h     = h
  m.d     = d*SCALE
  m.r     = math.max(w, h) -- For compatibilty with planet bois

  m.body    = love.physics.newBody(world, x, y, "dynamic")
  m.shape   = love.physics.newRectangleShape(w, h)
  m.fixture = love.physics.newFixture(m.body, m.shape, m.d)
  m.fixture:setRestitution(0.2)
  m.body:setAngle(rotation)

  m.maxThrust = m.body:getMass()*100  -- Maximum thrust
  m.maxTurnTq = m.body:getMass()/10 -- Maximum turning torque

  m.fTotalX, m.fTotalY = 0, 0  -- Total force on body

  --m.body:applyTorque(m.maxTurnTq)

  m.homing = homing
  m.target = target


  function m:tracking()
    self:turn()
    self:thrust()
  end

  function m:turn()
    local distance, x1, y1, x2, y2 = love.physics.getDistance(self.fixture, self.target.fixture)
    local angle = self.body:getAngle() % math.pi
    local theirAngle = getAngle(x1, y1, x2, y2)

    local targAngle = angle-theirAngle
    --local hmm =
    self.body:setAngle(theirAngle+(math.pi/2))

    print(theirAngle, angle, angle-theirAngle)
  end

  function m:thrust()
    local angle = self.body:getAngle()
    self.body:applyForce(math.sin(angle)*self.maxThrust, -math.cos(angle)*self.maxThrust)
  end

  function m:update(dt)
    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #bodies.planets do
      local dx, dy = getGravForce(self, bodies.planets[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    for i=1, #bodies.players do
      local dx, dy = getGravForce(self, bodies.players[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end

    if self.homing then
      self:tracking()
    end

    self.body:applyForce(self.fTotalX/SCALE, self.fTotalY/SCALE)
  end

  function m:draw()
    lg.push()
      lg.translate(self.body:getX(), self.body:getY())
      lg.rotate(self.body:getAngle())
      lg.setColor({1, 0.2, 0})
      lg.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
    lg.pop()


    if VEL_DEBUG then
      debugVel(self)
    end

    if FORCE_DEBUG then
      debugForce(self)
    end
  end

  --local velX, velY = getComponent(vel, rotation)
  m.body:setLinearVelocity(parentVelX, parentVelY)

  table.insert(bodies.missiles, m)
  return m
end
