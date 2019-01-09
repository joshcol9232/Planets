function Planet(id, pos, vel, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d

  p.body    = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape, p.d)
  p.fixture:setRestitution(0.4)

  p.fTotalX, p.fTotalY = 0, 0  -- Total force on body

  print(vel.x, vel.y, "Start Velocity")
  p.body:setLinearVelocity(vel.x, vel.y)


  function p:getGravForce(other)
    local xDist = other.body:getX() - self.body:getX()
    local yDist = other.body:getY() - self.body:getY()

    local dist  = love.physics.getDistance(self.fixture, other.fixture) + self.r + other.r
    local F = (G * self.body:getMass() * other.body:getMass())/(dist*dist)

    return F*xDist, F*yDist
  end

  function p:update()
    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #planets do
      if planets[i].id ~= self.id then
        local dx, dy = self:getGravForce(planets[i])
        self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
      end
    end
    self.body:applyForce(self.fTotalX, self.fTotalY)
  end

  function p:draw()
    lg.setColor({1, 1, 1})
    lg.circle("line", self.body:getX(), self.body:getY(), self.r)
  end

  -- Debug functions
  function p:debugVel()
    lg.setColor({0, 1, 0})
    local x, y = self.body:getX(), self.body:getY()
    local velX, velY = self.body:getLinearVelocity()
    lg.line(x, y, velX+x, velY+y)
  end

  function p:debugForce()
    lg.setColor({1, 0, 0})
    local x, y = self.body:getX(), self.body:getY()
    lg.line(x, y, (self.fTotalX/20)+x, (self.fTotalY/20)+y)
  end

  table.insert(planets, p)
  return p
end
