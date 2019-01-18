require "timerBar"

function Area(id, x, y, col, teamName, r, time)
  local a = {}
  a.id  = {} -- Id containing num
  a.x = x
  a.y = y
  a.col = col  -- Table with r, g and b
  a.teamName = teamName
  a.r = r
  a.rSqr = r^2
  a.timeLim = time -- Time to claim a planet

  a.planetsInside = {}
  a.times = {}

  function a:applyCircEquation(px, py) -- Uses equation of circle to check a point is inside circle
    local ans = (self.x - px)^2 + (self.y - py)^2
    return (ans <= self.rSqr) -- Returns true if the point is inside the circle
  end

  function a:checkForPlanet(dt) -- checks that planet is in it's area
    for i=1, #bodies.planets do
      local inside = self:applyCircEquation(bodies.planets[i].body:getPosition())
      if inside then
        local isInTable, index = inTable(self.planetsInside, bodies.planets[i])
        if not isInTable then
          table.insert(self.planetsInside, bodies.planets[i])
          table.insert(self.times, TimerBar(bodies.planets[i],
                                                           50,
                                                            8,
                                          bodies.planets[i].r,
                                          bodies.planets[i].r,
                                          self.timeLim))
        end
        if index > -1 then
          self.times[index]:incrementTime(dt)
          print(self.times[index].currTime)
        end
      else
        local isInTable, index = inTable(self.planetsInside, bodies.planets[i])
        if isInTable then
          table.remove(self.planetsInside, index)
          table.remove(self.times, index)  -- Should be mirror
        end
      end
    end
  end

  function a:draw()
    lg.setColor(self.col.r, self.col.g, self.col.b, 1)
    lg.circle("line", self.x, self.y, self.r)
    lg.setColor(self.col.r, self.col.g, self.col.b, 0.18)
    lg.circle("fill", self.x, self.y, self.r-1) -- -1 for line

    lg.setColor(self.col.r, self.col.g, self.col.b, 1)
    lg.print(self.teamName, self.x, self.y)

    for i=1, #self.times do
      self.times[i]:draw()
    end
  end

  function a:update(dt)
    self:checkForPlanet(dt)
  end

  return a
end
