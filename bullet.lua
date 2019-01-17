require "constants"
require "gravFuncs"
require "misc"

function Bullet(id, x, y, vel, w, h, d, rotation, parentVelX, parentVelY)
  local b = {}
  b.id    = id
  b.w     = w
  b.h     = h
  b.d     = d*SCALE
  b.r     = math.max(w, h) -- For compatibilty with planet bois

  b.body    = love.physics.newBody(world, x, y, "dynamic")
  b.shape   = love.physics.newRectangleShape(w, h)
  b.fixture = love.physics.newFixture(b.body, b.shape, b.d)
  b.fixture:setRestitution(0.2)
  b.body:setAngle(rotation)
  b.body:setBullet(true)
  b.fixture:setUserData({parentClass=b, userType="bullet"})

  b.totalTime = 0

  b.fTotalX, b.fTotalY = 0, 0

  function b:destroy()
    removeBody("bullet", self.id.num)
  end

  function b:checkTimeout()
    if self.totalTime >= BLT_TIMEOUT then
      self:destroy()
      return true
    end
    return false
  end

  function b:update(dt)
    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #bodies.planets do
      local dx, dy = getGravForce(self, bodies.planets[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    for i=1, #bodies.players do
      local dx, dy = getGravForce(self, bodies.players[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end

    self.body:applyForce(self.fTotalX/SCALE, self.fTotalY/SCALE)

    self.totalTime = self.totalTime + dt
  end

  function b:draw()
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
  b.body:setLinearVelocity(velX+parentVelX, velY+parentVelY)

  table.insert(bodies.bullets, b)
  return b
end
