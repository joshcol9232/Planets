require "gravFuncs"
require "debugFuncs"
require "constants"
require "misc"
require "hpBar"

function Planet(id, x, y, velx, vely, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d*SCALE

  p.captures = {}

  p.body    = love.physics.newBody(world, x, y, "dynamic")
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape, p.d)
  p.fixture:setRestitution(0.4)
  p.fixture:setUserData({parentClass=p, userType="planet"})

  p.hp = p.body:getMass()/SCALE
  p.maxHp = p.hp
  print(p.hp, "Planet hp")

  p.fTotalX, p.fTotalY = 0, 0  -- Total force on body

  p.body:setLinearVelocity(velx, vely)

  function p:changeHp(change)
    self.hp = self.hp+change
    if self.hp < 0 then
      self.hp = 0
      return true
    elseif self.hp > self.maxHp then
      self.hp = self.maxHp
    end
  end

  function p:getSplitVelocities(num)
    local vels = {}
    for i=1, math.ceil(num/2) do
      local totalV = math.random(50, PL_SPLIT_SPEED)
      local angle = math.random()*math.pi*2 -- Gets number between 0 and 1, then multiplies that by 2pi
      local dx, dy = totalV*math.cos(angle), totalV*math.sin(angle)
      table.insert(vels, {x=dx, y=dy})
    end
    for i=1, #vels do
      table.insert(vels, {x=-vels[i].x, y=-vels[i].y})  -- To conserve momentum, half need to have opposite velocity
    end
    return vels
  end

  function p:destroy(splitFactor)
    local r = self.shape:getRadius()
    if r > 1 then
      if splitFactor == nil then
        splitFactor = math.random(2, 6)
      end
      local x, y = self.body:getX(), self.body:getY()
      local vx, vy = self.body:getLinearVelocity()
      removeBody("planet", self.id.num)
      r = r/splitFactor
      local sep = r/2
      local vels = self:getSplitVelocities(splitFactor^2)
      local a = 0
      for i=1, splitFactor do
        for j=1, splitFactor do
          a = a + 1
          local p = Planet({type="planet", num=#bodies.planets+1}, (x+(i*sep)), (y+(j*sep)), vx+vels[a].x, vy+vels[a].y, r, PL_DENSITY)
          table.insert(bodies.planets, p)
          if math.random(0, 10) == 1 then
            p:destroy(2)
          end
        end
      end
      print("Total mass:", getTotalMassInWorld())
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

    if (self.hp < self.maxHp) and (self.hpBar ~= nil) then
      self.hpBar:draw()
    end
  end

  --(parent, w, h, pW, pH)
  if p.r > 4 then
    p.hpBar = HpBar(p, 70, 10, p.r, p.r)
  end
  return p
end
