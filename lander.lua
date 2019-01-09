function Lander(id, x, y, vel, w, h, d)
  local l = {}
  l.playerId = id
	l.w     = w
  l.h     = h
  l.d     = d
	l.r     = math.max(w, h) -- For compatibilty with planet bois

  l.body    = love.physics.newBody(world, x, y, "dynamic")
  l.shape   = love.physics.newRectangleShape(w, h)
  l.fixture = love.physics.newFixture(l.body, l.shape, l.d)
  l.fixture:setRestitution(0.2)

  l.fTotalX, l.fTotalY = 0, 0  -- Total force on body
  l.rotationFactor = 200000
  l.thrustLevel = 0.0         -- Thrust level from 0 to 1
  l.thrustFactor = 50000  -- Multiplyer

  l.body:setLinearVelocity(vel.x, vel.y)

  function l:thrust()
    local angle = self.body:getAngle()
    return math.sin(angle)*self.thrustLevel*self.thrustFactor, -math.cos(angle)*self.thrustLevel*self.thrustFactor
  end

	function l:changeThrust(amount)
		if self.thrustLevel+amount <= 1 and self.thrustLevel+amount >= 0 then
			self.thrustLevel = self.thrustLevel + amount
		end
	end

  function l:turnLeft()
    self.body:applyTorque(-self.rotationFactor)
  end

  function l:turnRight()
    self.body:applyTorque(self.rotationFactor)
  end

  function l:getGravForce(other)
    local xDist = other.body:getX() - self.body:getX()
    local yDist = other.body:getY() - self.body:getY()

    local dist  = love.physics.getDistance(self.fixture, other.fixture) + self.r + other.r
    local F = (G * self.body:getMass() * other.body:getMass())/(dist*dist)

    return F*xDist, F*yDist
  end

  function l:update()
		--local bodX, bodY = self.body:getX(), self.body:getY()
		--if bodX < 0 then

    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #planets do
      local dx, dy = self:getGravForce(planets[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    local tX, tY = self:thrust()
    self.fTotalX, self.fTotalY = self.fTotalX+tX, self.fTotalY+tY
    self.body:applyForce(self.fTotalX, self.fTotalY)
  end

  function l:draw()
    lg.setColor({1, 1, 1})
		lg.push()
			lg.translate(self.body:getX(), self.body:getY())
			lg.rotate(self.body:getAngle())
			--lg.rectangle("line", -self.w/2, -self.h/2, self.w, self.h)
			lg.draw(landerImg, -self.w/2, -self.h/2)
			lg.setColor({1, 0, 0})
		  lg.line(0, self.h/2, 0, (self.h/2)+(self.thrustLevel*50))
		lg.pop()

    if VEL_DEBUG then
      self:debugVel()
    end

    if FORCE_DEBUG then
      self:debugForce()
    end
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
    lg.line(x, y, (self.fTotalX/20)+x, (self.fTotalY/20)+y)
  end

  return l
end
