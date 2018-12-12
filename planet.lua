function Planet(id, pos, vel, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d

  p.body    = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  p.body:setLinearVelocity(vel.x, vel.y)
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape, p.d)
  p.fixture:setRestitution(0.2)
  p.fixture:setFriction(1)

  function p:draw()
    lg.setColor({1, 1, 1})
    lg.circle("line", self.body:getX(), self.body:getY(), self.r)
  end

  function p:getGravForce(other)
    local xDist = other.body:getX() - self.body:getX()
    local yDist = other.body:getY() - self.body:getY()

    local dist  = love.physics.getDistance(self.fixture, other.fixture) + self.r + other.r
    local F = (G * self.body:getMass() * other.body:getMass())/(dist*dist)

    return F*xDist, F*yDist
  end

  function p:update()
    local fTotalX, fTotalY = 0, 0
    for i=1, #planets do
      if planets[i].id ~= self.id then
        local dx, dy = self:getGravForce(planets[i])
        fTotalX, fTotalY = fTotalX + dx, fTotalY + dy
      end
    end
    self.body:applyForce(fTotalX, fTotalY)
  end

  table.insert(planets, p)
  return p
end
