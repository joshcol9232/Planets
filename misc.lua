function inTable(table, item)
	for i=1, #table do
		if table[i] == item then
			return true
		end
	end
	return false
end

-- Vectors
function getAngle(x1,y1, x2,y2) --Get angle from Top
	return math.atan2(y2-y1, x2-x1)
end

function getComponent(v, angle)  -- Gets x y components of vector v
	return math.sin(angle)*v, -math.cos(angle)*v
end
-- 
-- function getMag(x, y)
-- 	return math.sqrt(math.pow(self.x,2) + math.pow(self.y,2))
-- end
