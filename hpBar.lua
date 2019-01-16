function HpBar(parent, width, height, pW, pH)
  local h = {}
  h.width = width
  h.height = height
  h.pW = pW
  h.pH = pH
  h.parent = parent

  h.parentX, h.parentY = parent.body:getX(), parent.body:getY()

  function h:drawFrame(x, y)
    lg.line(x, y, x+self.width, y) -- Top line
    lg.line(x, y, x, y+self.height) -- Left line
    lg.line(x+self.width, y, x+self.width, y+self.height) -- Right line
    lg.line(x, y+self.height, x+self.width, y+self.height) -- Bottom line
  end

  function h:draw()
    lg.setColor({1, 1, 1})
    self.parentX, self.parentY = self.parent.body:getX(), self.parent.body:getY()
    local x = self.parentX - (self.width/2)
    local y = self.parentY + (self.pH*(6/5))

    self:drawFrame(x, y)

    lg.setColor({1, 0, 0})
    lg.rectangle("fill", x+1, y+1, self.width*(self.parent.hp/self.parent.maxHp)-2, self.height-2) -- -2 for the frame width
  end

  return h
end
