require "gravFuncs"
require "debugFuncs"
require "constants"
require "misc"
require "hpBar"
require "splitFunctions"
require "animation"

function Planet(id, x, y, velx, vely, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d*SCALE
  p.alpha = 1 -- Transparency

  p.captures = {}
  p.destroyed = false

  p.body    = love.physics.newBody(world, x, y, "dynamic")
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape, p.d)
  p.fixture:setRestitution(0.4)
  p.fixture:setUserData({parentClass=p, userType="planet"})

  p.fTotalX, p.fTotalY = 0, 0  -- Total force on body
  p.hasTimeout = (r <= PL_TIMEOUT_THRESHOLD_R)

  p.fading = false

  p.hp = (p.r/SCALE)*10000000
  p.maxHp = p.hp

  if p.hasTimeout then
    p.timeLimit = math.random()+math.random(PL_TIMEOUT/1.5, PL_TIMEOUT)  -- Increases randomness of despawning, rather than them all despawning at once, if they were all created at once.
    p.totalTime = 0
  end

  p.body:setLinearVelocity(velx, vely)

  function p:changeHp(change)
    self.hp = self.hp+change
    self.hpBar:showEnable()
    if self.hp <= 0 then
      self.hp = 0
      self:destroy()
    elseif self.hp > self.maxHp then
      self.hp = self.maxHp
    end
  end

  function p:destroy(splitFactor)
    local r = self.shape:getRadius()
    if r > 1 then
      if splitFactor == nil then
        splitFactor = math.random(2, 6)
        if splitFactor % 2 ~= 0 then splitFactor = splitFactor + 1 end
      end
      local x, y = self.body:getX(), self.body:getY()
      local vx, vy = self.body:getLinearVelocity()
      r = r/splitFactor
      local sep = r/2
      local vels = getSplitVelocities(splitFactor^2)
      local a = 0
      for i=1, splitFactor do
        for j=1, splitFactor do
          a = a + 1
          local p = Planet({type="planet", num=#bodies.planets+1}, (x+(i*sep)), (y+(j*sep)), vx+vels[a].x, vy+vels[a].y, r, PL_DENSITY)
          if math.random(0, PL_CHANCE_OF_SECOND_SPLIT) == 1 then
					  p:destroy(2)
          end
          table.insert(bodies.planets, p)
        end
      end
      removeBody("planet", self.id.num, bodies.planets)
      self.destroyed = true
    end
  end

  function p:update(dt)
    self.fTotalX, self.fTotalY = 0, 0
    for i=1, #bodies.planets do
      if bodies.planets[i].id.num ~= self.id.num then
        local dx, dy = getGravForce(self, bodies.planets[i])
        self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
      end
    end

    for i=1, #bodies.players do
      local dx, dy = getGravForce(self, bodies.players[i])
      self.fTotalX, self.fTotalY = self.fTotalX + dx, self.fTotalY + dy
    end
    self.body:applyForce(self.fTotalX/SCALE, self.fTotalY/SCALE)

    --local contacts = self.body:getContactList()
    if self.hasTimeout then
      self.totalTime = self.totalTime + dt
    end

    if self.fading then
      fade(self, dt)
    end
    self.hpBar:update(dt)
  end

  function p:draw()
    lg.setColor(1, 1, 1, self.alpha)
    lg.circle("line", self.body:getX(), self.body:getY(), self.r)
    if VEL_DEBUG then
      debugVel(self)
    end

    if FORCE_DEBUG then
      debugForce(self)
    end

    self.hpBar:draw()
  end

  --(parent, w, h, pW, pH)
  p.hpBar = HpBar(p, 70, 10, p.r, p.r)
  return p
end
