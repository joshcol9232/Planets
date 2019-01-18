require "statusBar"

function HpBar(parent, width, height, pW, pH)
  local h = StatusBar(parent, width, height, pW, pH) -- Inherits

  function h:draw()
    lg.setColor({1, 1, 1})
    self.parentX, self.parentY = self.parent.body:getX(), self.parent.body:getY()
    local x = self.parentX - (self.width/2)
    local y = self.parentY + (self.pH*(6/5))

    self:drawFrame(x, y)

    local normHp = self.parent.hp/self.parent.maxHp
    lg.setColor({1-normHp, normHp, 0})
    lg.rectangle("fill", x+1, y+1, self.width*(normHp)-2, self.height-2) -- -2 for the frame width
  end

  return h
end
