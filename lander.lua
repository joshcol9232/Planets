require "debugFuncs"
require "gravFuncs"

function Lander(id, x, y, velx, vely, w, h, d)
  local l = {}
  l.id = id
	l.w     = w
  l.h     = h
  l.d     = d
	l.r     = math.max(w, h) -- For compatibilty with planet bois

  l.leftKey  = "a"
  l.rightKey = "d"
  l.upKey    = "w"
  l.downKey  = "s"
  if l.id == 2 then
    l.leftKey  = "left"
    l.rightKey = "right"
    l.upKey    = "up"
    l.downKey  = "down"
  end

  l.body    = love.physics.newBody(world, x, y, "dynamic")
  l.shape   = love.physics.newRectangleShape(w, h)
  l.fixture = love.physics.newFixture(l.body, l.shape, l.d)
  l.fixture:setRestitution(0.2)
  l.Type = "lander"

  l.fTotalX, l.fTotalY = 0, 0  -- Total force on body
  l.rotationFactor = 100000000
  l.thrustLevel = 0.0         -- Thrust level from 0 to 1
  l.thrustChange = 0.04       -- Amount the thrust changes when changing thrust
  l.maxThrust = 6520000000--65200000  -- Maximum thrust

  l.body:setLinearVelocity(0, -10000)--velx, vely)

  function l:destroySelf()
    self.body:destroy()
    print(self, player1, "Self should be nil")
  end

  function l:thrust()
    local angle = self.body:getAngle()
    return math.sin(angle)*self.thrustLevel*self.maxThrust, -math.cos(angle)*self.thrustLevel*self.maxThrust
  end

	function l:changeThrust(amount)
		if self.thrustLevel+amount <= 0 then   -- Prevents stupid 0 error (where 0.02 - 0.02 is apparently 2.4e-17)
      self.thrustLevel = 0
    elseif self.thrustLevel+amount >= 1 then
      self.thrustLevel = 1
    else
      self.thrustLevel = self.thrustLevel+amount
    end
	end

  function l:turnLeft()
    self.body:applyTorque(-self.rotationFactor)
  end

  function l:turnRight()
    self.body:applyTorque(self.rotationFactor)
  end

  function l:update(dt)
    if love.keyboard.isDown(self.leftKey) then
      self:turnLeft()
    end
    if love.keyboard.isDown(self.rightKey) then
      self:turnRight()
    end
    if love.keyboard.isDown(self.upKey) then
      self:changeThrust(self.thrustChange)
    else
      self:changeThrust(-0.06)
    end

    -- contacts = self.body:getContacts()
    -- if #contacts > 0 then
    --   print("Touching something")
    --   self:destroySelf()
    -- end

    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #planets do
      local dx, dy = getGravForce(self, planets[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    for i=1, #players do
      if players[i].id ~= self.id then
        local dx, dy = getGravForce(self, players[i])
        self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
      end
    end

    local tX, tY = self:thrust()
    self.fTotalX, self.fTotalY = self.fTotalX+tX, self.fTotalY+tY
    print(self.body:getLinearVelocity())
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
		  lg.line(0, self.h/2, 0, (self.h/2)+(self.thrustLevel*20))
		lg.pop()

    if VEL_DEBUG then
      debugVel(self)
    end

    if FORCE_DEBUG then
      debugForce(self)
    end
  end

  return l
end
