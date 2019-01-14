require "gravFuncs"
require "debugFuncs"
require "constants"
require "misc"

function Planet(id, x, y, velx, vely, r, d)
  local p = {}
  p.id    = id
  p.r     = r
  p.d     = d*SCALE

  p.body    = love.physics.newBody(world, x, y, "dynamic")
  p.shape   = love.physics.newCircleShape(r)
  p.fixture = love.physics.newFixture(p.body, p.shape, p.d)
  p.fixture:setRestitution(0.4)

  p.fTotalX, p.fTotalY = 0, 0  -- Total force on body

  p.body:setLinearVelocity(velx, vely)

  function p:destroy()
    local r = self.shape:getRadius()
    local x, y = self.body:getX(), self.body:getY()
    local vx, vy = self.body:getLinearVelocity()
    removePlanet(self.id.num)
    r = r/PL_SPLIT_FACTOR
    for i=-2, 2 do
      for j=-2, 2 do
        table.insert(bodies.planets, Planet({type="planet", num=#bodies.planets+1}, (x+(i*r)), (y+(j*r)), vx+(i*30), vy+(j*30), r, PL_DENSITY))
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
