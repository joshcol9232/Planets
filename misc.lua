
-- Returns the angle between two points.
function getAngle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end

function getRelativeAngle(v1, v2)
	return math.atan(v1.x, v1.y) - math.atan(v2.x, v2.y)
end

function getDist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

