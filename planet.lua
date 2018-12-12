function Planet(id, pos, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d

  p.body    = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape)

  function p:draw()
    love.graphics.setColor({1, 1, 1})
    print(self.body:getX(), self.body:getY())
    love.graphics.circle("line", self.body:getX(), self.body:getY(), self.r)
  end

  function p:getGravForce(other)
    local dist = love.physics.getDistance(self.fixture, other.fixture)
    local angle = getAngle(self.body:getX(), self.body:getY(), other.body:getX(), other.body:getY())
    local F = (G * self.body:getMass() * other.body:getMass())/(dist*dist)
    return F*math.Sin(angle), F*math.Cos(angle)
  end

  function p:update()
    local fTotalX, fTotalY = 0, 0
    for i, #planets do
      if planets[i].id != self.id then
        local dx, dy = self.getGravForce(planets[i])
        fTotalX, fTotalY = fTotalX + dx, fTotalY + dy
      end
    end
    self.body.applyForce(fTotalX, fTotalY)
  end

  table.insert(planets, p)
  return p
end
