require "constants"
require "gravFuncs"

function Bullet(x, y, velx, vely, w, h, d, rotation)
  local b = {}
  b.w     = w
  b.h     = h
  b.d     = d*SCALE
  b.r     = math.max(w, h) -- For compatibilty with planet bois

  b.body    = love.physics.newBody(world, x, y, "dynamic")
  b.shape   = love.physics.newRectangleShape(w, h)
  b.fixture = love.physics.newFixture(b.body, b.shape, b.d)
  b.fixture:setRestitution(0.2)
  b.body:setAngle(rotation)

  b.Type = "bullet"

  function b:update()
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

    self.body:applyForce(self.fTotalX/SCALE, self.fTotalY/SCALE)
  end

  function b:draw()
    lg.push()
      lg.translate(self.body:getX(), self.body:getY())
      lg.rotate(self.body:getAngle())
      lg.setColor({1, 0.2, 0})
      lg.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
    lg.pop()
  end

  table.insert(bullets, b)
  return b
end
