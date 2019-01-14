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

  m.maxThrust = m.body:getMass()*2000  -- Maximum thrust
  m.maxTurnTq = m.body:getMass()*1000 -- Maximum turning torque

  m.fTotalX, m.fTotalY = 0, 0  -- Total force on body

  --m.body:applyTorque(m.maxTurnTq)

  m.homing = homing
  m.target = target

  function m:getAngleOfVel(vx, vy)
    return ((math.atan2(vy, vx)+math.pi) % (2*math.pi))
  end

  function m:tracking()
    local distance, x, y, oX, oY = love.physics.getDistance(self.fixture, self.target.fixture)
    local vx, vy = self.body:getLinearVelocity()
    self:turn(x, y, oX, oY, vx, vy)
    local fx, fy = self:thrust()
    self.fTotalX, self.fTotalY = self.fTotalX + fx, self.fTotalY + fy
  end

  function m:turn(x, y, oX, oY, vx, vy)  -- Current angle from target
    --local selfAngle = ((self.body:getAngle()+(math.pi/2)) % (2*math.pi)) --self:getAngleOfVel()

    local targAngle = ((getAngle(x, y, oX, oY)+(math.pi))%(2*math.pi))
    --print(targAngle, selfAngle)--, selfAngle)--, targAngle-selfAngle)

    local correction = targAngle---selfAngle  -- If negative, then turn right, (too far left), if pos then turn left
    --+(self:getAngleOfVel()/targAngle)

    --self.body:applyTorque(self.maxTurnTq*(correction-self.body:getAngularVelocity()))
    self.body:setAngle(correction-(math.pi/2))
  end

  function m:thrust()
    local angle = self.body:getAngle()
    return math.sin(angle)*self.maxThrust, -math.cos(angle)*self.maxThrust
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
