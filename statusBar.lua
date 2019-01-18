function StatusBar(parent, width, height, pW, pH)
  local s = {}
  s.width = width
  s.height = height
  s.pW = pW
  s.pH = pH
  s.parent = parent

  s.parentX, s.parentY = parent.body:getX(), parent.body:getY()

  function s:drawFrame(x, y)
    lg.line(x, y, x+self.width, y) -- Top line
    lg.line(x, y, x, y+self.height) -- Left line
    lg.line(x+self.width, y, x+self.width, y+self.height) -- Right line
    lg.line(x, y+self.height, x+self.width, y+self.height) -- Bottom line
  end

  return s
end
