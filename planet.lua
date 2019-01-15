require "gravFuncs"
require "debugFuncs"
require "constants"
require "misc"

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

  p.fTotalX, p.fTotalY = 0, 0  -- Total force on body

  p.body:setLinearVelocity(velx, vely)

  function p:getSplitVelocities(num)
    local vels = {}
    for i=1, math.ceil(num/2) do
      local totalV = math.random(20, PL_SPLIT_SPEED)
      local angle = math.random()*math.pi*2
      local dx, dy = totalV*math.cos(angle), totalV*math.sin(angle)
      table.insert(vels, {x=dx, y=dy})
    end
    for i=1, #vels do
      table.insert(vels, {x=-vels[i].x, y=-vels[i].y})
    end
    return vels
  end

  function p:destroy()
    local r = self.shape:getRadius()
    print(self.body)
    local x, y = self.body:getX(), self.body:getY()
    local vx, vy = self.body:getLinearVelocity()
    removeBody("planet", self.id.num)
    local splitFactor = math.random(2, 6)
    r = r/splitFactor
    local vels = self:getSplitVelocities(splitFactor^2)
    a = 0
    for i=1, splitFactor do
      for j=1, splitFactor do
        a = a + 1
        print(#vels, a)
        table.insert(bodies.planets, Planet({type="planet", num=#bodies.planets+1}, (x+(i*r)), (y+(j*r)), vx+vels[a].x, vy+vels[a].y, r, PL_DENSITY))
      end
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
  end

  return p
end
