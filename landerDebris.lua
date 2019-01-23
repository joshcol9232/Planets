function LanderDebris(id, x, y, velx, vely, angle, rotatVel, timeout, num)
  local d = {}
  d.poly = landerDebris[num]
  d.id = id
  d.alpha = 1 -- Transparency
  d.fading = false

  d.body    = love.physics.newBody(world, x, y, "dynamic")
  d.shape   = love.physics.newPolygonShape(d.poly)
  d.fixture = love.physics.newFixture(d.body, d.shape, LD_DENSITY*SCALE)
  d.fixture:setUserData({parentClass=d, userType="landerDebris"})
  d.body:setAngle(angle)
  d.body:setAngularVelocity(rotatVel)
  d.body:setLinearVelocity(velx, vely)
  d.r = d.shape:getRadius()
  d.body:setBullet(true)

  d.totalTime = 0

  d.fTotalX, d.fTotalY = 0, 0

  function d:draw()
    lg.setColor(1, 1, 1, self.alpha)
    lg.push()
      lg.translate(self.body:getX(), self.body:getY())
      lg.rotate(self.body:getAngle())

      lg.polygon("line", self.poly)
    lg.pop()
  end

  function d:update(dt)
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

    if self.fading then
      fade(self, dt)
    end
  end

  table.insert(bodies.debris, d)
  return d
end
