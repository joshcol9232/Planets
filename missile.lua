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

  m.maxThrust = m.body:getMass()*1000  -- Maximum thrust
  m.maxTurnTq = m.body:getMass()*1000 -- Maximum turning torque

  m.homing = homing
  m.target = target

  function m:tracking()
    local distance, x, y, oX, oY = love.physics.getDistance(self.fixture, self.target.fixture)
    local angle = getAngle(x, y, oX, oY)
    self:turn(angle)

  end

  function m:turn(targAngle)  -- Current angle from target
    print(targAngle)
  end

  function m:thrust()
    local angle = self.body:getAngle()
    return math.sin(angle)*self.maxThrust, -math.cos(angle)*self.maxThrust
  end

  function m:update(dt)
    if self.homing then
      self:tracking()
    end
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

  local velX, velY = getComponent(vel, rotation)
  m.body:setLinearVelocity(velX+parentVelX, velY+parentVelY)

  table.insert(bodies.missiles, m)
  return m
end
