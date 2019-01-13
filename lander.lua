require "debugFuncs"
require "gravFuncs"
require "constants"
require "bullet"

function Lander(id, x, y, velx, vely, w, h, d)
  local l = {}
  l.id    = id
	l.w     = w
  l.h     = h
  l.d     = d*SCALE
	l.r     = math.max(w, h) -- For compatibilty with planet bois

  l.leftKey  = "a"
  l.rightKey = "d"
  l.upKey    = "w"
  l.downKey  = "s"
  l.fireKey  = "e"
  if l.id.num == 9999999 then
    l.leftKey  = "left"
    l.rightKey = "right"
    l.upKey    = "up"
    l.downKey  = "down"
    l.fireKey  = "kp0" -- Key pad 0
  end

  l.body    = love.physics.newBody(world, x, y, "dynamic")
  l.shape   = love.physics.newRectangleShape(w, h)
  l.fixture = love.physics.newFixture(l.body, l.shape, l.d)
  l.fixture:setRestitution(0.2)
  l.mass = l.body:getMass()

  l.turnKeyDown = false
  l.targetOn = false

  l.fTotalX, l.fTotalY = 0, 0  -- Total force on body
  l.rotationFactor = l.mass*1000
  l.thrustLevel = 0.0         -- Thrust level from 0 to 1
  l.thrustChange = 0.04       -- Amount the thrust changes when changing thrust
  l.maxThrust = l.mass*10000  -- Maximum thrust

  l.body:setLinearVelocity(velx, vely)

  l.lastFire = love.timer.getTime()

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

  function l:reactionControl(delT)
    local v = self.body:getAngularVelocity()
    v = (v/LD_DAMPENING^delT)   -- y = y/LD_DAMPENING^x == slope from y=1
    self.body:setAngularVelocity(v)
  end

  function l:getXYTopOfObj(angle)
    return self.body:getX()+(math.sin(angle)*self.w/2), self.body:getY()-(math.cos(angle)*self.h/2)
  end

  function l:fireBullet()
    local angle = self.body:getAngle()
    local topX, topY = self:getXYTopOfObj(angle)
    local b = Bullet(topX, topY,
                     BLT_VELOCITY,
                     BLT_DIMENSION, BLT_DIMENSION*2,
                     BLT_DENSITY,
                     angle,
                     self.body:getLinearVelocity())

    local fx, fy = b.body:getLinearVelocity()
    self.body:applyForce(-fx*b.body:getMass(), -fy*b.body:getMass())
  end

  function l:getNearestPlayer() -- In lander so that the user gets the view of what lander to target
    local closestPlayer = {dist=-1, player=nil}
    for i=1, #bodies.players do
      if bodies.players[i].id.num ~= self.id.num then
        local distance = love.physics.getDistance(self.fixture, bodies.players[i].fixture)
        if closestPlayer.dist < distance then
          closestPlayer = {dist=distance, player=bodies.players[i]}
        end
      end
    end
    return closestPlayer.player, closestPlayer.dist
  end

  function l:drawMissileTarget(otherPl)
    lg.setColor({1, 0, 0})
    local otherX, otherY = otherPl.body:getX(), otherPl.body:getY()

    lg.line(otherX-20, otherY-20, otherX-20, otherY+20) -- Furthest left large
    lg.line(otherX-20, otherY-20, otherX-10, otherY-20) -- Furthest left two smaller parts
    lg.line(otherX-20, otherY+20, otherX-10, otherY+20)

    lg.line(otherX+20, otherY-20, otherX+20, otherY+20) -- Furthest right large
    lg.line(otherX+20, otherY-20, otherX+10, otherY-20) -- Furthest right smaller parts
    lg.line(otherX+20, otherY+20, otherX+10, otherY+20)
  end

  function l:update(dt)
    local leftD, rightD = love.keyboard.isDown(self.leftKey), love.keyboard.isDown(self.rightKey)
    self.turnKeyDown = leftD or rightD
    if leftD then
      self:turnLeft()
    end
    if rightD then
      self:turnRight()
    end
    if love.keyboard.isDown(self.upKey) then
      self:changeThrust(self.thrustChange)
    else
      self:changeThrust(-0.06)
    end

    if love.keyboard.isDown(self.fireKey) then
      local currTime = love.timer.getTime()
      if currTime-self.lastFire > LD_FIRE_RATE then
        self.lastFire = currTime
        self:fireBullet()
      end
    end

    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #bodies.planets do
      local dx, dy = getGravForce(self, bodies.planets[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    for i=1, #bodies.players do
      if bodies.players[i].id.num ~= self.id.num then
        local dx, dy = getGravForce(self, bodies.players[i])
        self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
      end
    end

    local tX, tY = self:thrust()
    self.fTotalX, self.fTotalY = self.fTotalX+tX, self.fTotalY+tY
    self.body:applyForce(self.fTotalX/SCALE, self.fTotalY/SCALE)

    if dampening and (not self.turnKeyDown) then
      self:reactionControl(dt)
    end
  end

  function l:draw()
    lg.setColor({1, 1, 1})
		lg.push()
			lg.translate(self.body:getX(), self.body:getY())
      if self.id.num == 9999999 then lg.print("2", 0, -25) else
        lg.print(self.id.num, 0, -25)
      end
			lg.rotate(self.body:getAngle())
			--lg.rectangle("line", -self.w/2, -self.h/2, self.w, self.h)
			lg.draw(landerImg, -self.w/2, -self.h/2)
			lg.setColor({1, 0, 0})
		  lg.line(0, self.h/2, 0, (self.h/2)+(self.thrustLevel*20))
		lg.pop()

    if self.targetOn and #bodies.players > 1 then
      local otherPl, dist = self:getNearestPlayer()
      self:drawMissileTarget(otherPl)
    end

    if VEL_DEBUG then
      debugVel(self)
    end

    if FORCE_DEBUG then
      debugForce(self)
    end
  end

  return l
end
