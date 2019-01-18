require "statusBar"

function TimerBar(parent, width, height, pW, pH, maxTime)
  local t = StatusBar(parent, width, height, pW, pH) -- Inherits
  t.max = maxTime
  t.currTime = 0

  function t:incrementTime(amount)
    if self.currTime+amount > self.max then
      self.currTime = self.max
      return true
    else
      self.currTime = self.currTime + amount
    end
  end

  function t:draw()
    lg.setColor({1, 1, 1})
    self.parentX, self.parentY = self.parent.body:getX(), self.parent.body:getY()
    local x = self.parentX - (self.width/2)
    local y = self.parentY + (self.pH)--*(6/5))

    self:drawFrame(x, y)

    local normTime = self.currTime/self.max
    lg.setColor({1-normTime, normTime, 0})
    lg.rectangle("fill", x+1, y+1, self.width*(normTime)-2, self.height-2) -- -2 for the frame width
  end

  return t
end
