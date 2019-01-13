require "gravFuncs"
require "debugFuncs"
require "constants"

function Planet(id, x, y, velx, vely, r, d)
  print(id, x, y, velx, vely, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d*SCALE

  p.body    = love.physics.newBody(world, x, y, "dynamic")
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape, p.d)
  p.fixture:setRestitution(0.4)

  p.fTotalX, p.fTotalY = 0, 0  -- Total force on body

  print(velx, vely, "Start Velocity")
  p.body:setLinearVelocity(velx, vely)

  function p:update(dt)
    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #planets do
      if planets[i].id ~= self.id then
        local dx, dy = getGravForce(self, planets[i])
        self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
      end
    end

    for i=1, #players do
      local dx, dy = getGravForce(self, players[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    self.body:applyForce(self.fTotalX/SCALE, self.fTotalY/SCALE)
  end

  function p:draw()
    lg.setColor({1, 1, 1})
    lg.circle("line", self.body:getX(), self.body:getY(), self.r)
    if VEL_DEBUG then
      debugVel(self)
    end

    if FORCE_DEBUG then
      debugForce(self)
    end
  end

  return p
end
