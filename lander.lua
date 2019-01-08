function Lander(id, pos, vel, w, h, d)
  local l = {}
  l.id    = id
	l.w     = w
  l.h     = h
  l.d     = d
	l.r     = math.max(w, h) -- For compatibilty with planet bois

  l.body    = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  l.shape   = love.physics.newRectangleShape(w, h)
  l.fixture = love.physics.newFixture(l.body, l.shape, l.d)
  l.fixture:setRestitution(0.6)

  l.fTotalX, l.fTotalY = 0, 0  -- Total force on body
	l.Type = "lander"

  print(vel.x, vel.y, "Start Velocity")
  l.body:setLinearVelocity(vel.x, vel.y)

  function l:getGravForce(other)
    local xDist = other.body:getX() - self.body:getX()
    local yDist = other.body:getY() - self.body:getY()

    local dist  = love.physics.getDistance(self.fixture, other.fixture) + self.r + other.r
    local F = (G * self.body:getMass() * other.body:getMass())/(dist*dist)

    return F*xDist, F*yDist
  end

  function l:update()
    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #bodies do
      if bodies[i].id ~= self.id then
        local dx, dy = self:getGravForce(bodies[i])
        self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
      end
    end
    self.body:applyForce(self.fTotalX, self.fTotalY)
  end

  function l:draw()
    lg.setColor({1, 1, 1})
		lg.push()
			lg.translate(self.body:getX(), self.body:getY())
			lg.rotate(self.body:getAngle())
			lg.rectangle("line", -self.w/2, -self.h/2, self.w, self.h)
		lg.pop()
    --self:debugVel()
    --self:debugForce()
  end

  -- Debug functions
  function l:debugVel()
    lg.setColor({0, 1, 0})
    local x, y = self.body:getX(), self.body:getY()
    local velX, velY = self.body:getLinearVelocity()
    lg.line(x, y, velX+x, velY+y)
  end

  function l:debugForce()
    lg.setColor({1, 0, 0})
    local x, y = self.body:getX(), self.body:getY()
    lg.line(x, y, (self.fTotalX/20000)+x, (self.fTotalY/20000)+y)
  end

  table.insert(bodies, l)
  return l
end
