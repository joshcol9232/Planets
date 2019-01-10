-- Debug functions
function debugVel(obj)
  lg.setColor({0, 1, 0})
  local x, y = obj.body:getX(), obj.body:getY()
  local velX, velY = obj.body:getLinearVelocity()
  lg.line(x, y, velX+x, velY+y)
end

function debugForce(obj)
  lg.setColor({1, 0, 0})
  local x, y = obj.body:getX(), obj.body:getY()
  lg.line(x, y, (obj.fTotalX/100000)+x, (obj.fTotalY/100000)+y)
end
