
-- Returns the angle between two points.
function getAngle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end