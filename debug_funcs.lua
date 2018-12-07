
function drawDebugSettings()
	local DEBUG_SETTINGS = {
		{"Draw Collisions",  DRAW_COLLISIONS},
		{"Draw Momentum",    DRAW_MOMENTUM},
		{"Draw Connections", DRAW_CONNECTIONS}
	}
		
	for i=1, #DEBUG_SETTINGS do
		if DEBUG_SETTINGS[i][2] == true then
			lg.setColor(LGRAY)
		else
			lg.setColor(DGRAY)
		end
		lg.print(tostring(i)..": "..DEBUG_SETTINGS[i][1], 8, 8+(i*8))
	end
end