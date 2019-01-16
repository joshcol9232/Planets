function getSplitVelocities(num)
  local vels = {}
  for i=1, math.ceil(num/2) do
    local totalV = math.random(50, PL_SPLIT_SPEED)
    local angle = math.random()*math.pi*2 -- Gets number between 0 and 1, then multiplies that by 2pi
    local dx, dy = totalV*math.cos(angle), totalV*math.sin(angle)
    table.insert(vels, {x=dx, y=dy})
  end
  for i=1, #vels do
    table.insert(vels, {x=-vels[i].x, y=-vels[i].y})  -- To conserve momentum, half need to have opposite velocity
  end
  return vels
end
