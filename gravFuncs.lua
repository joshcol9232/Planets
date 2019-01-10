function getGravForce(obj, other)
  local xDist = other.body:getX() - obj.body:getX()
  local yDist = other.body:getY() - obj.body:getY()

  local dist  = love.physics.getDistance(obj.fixture, other.fixture) + obj.r + other.r
  local F = (G * obj.body:getMass() * other.body:getMass())/(dist*dist)

  return F*xDist, F*yDist
end
