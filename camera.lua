function Camera(x, y)
	local c = {}
	c.x    	= x
	c.y    	= y
	c.angle = 0 -- From directly up
	c.zoom = 1
	c.followPlayer = true
	c.followPlayerAngle = false
	c.playerIDToFollow = 1
	c.playerBody = nil
	c.transformation = love.math.newTransform(-c.x, -c.y, c.angle, c.zoom, c.zoom, 0, 0, 0, 0)
	c.angleTransform = love.math.newTransform(-SCREEN_WIDTH/2, -SCREEN_HEIGHT/2, c.angle)

	function c:inverseTransformPoint(x, y)
		return self.transformation:inverseTransformPoint(x, y)
	end

	function c:trackPlayer(playerBody)
		self.x, self.y = playerBody:getPosition()
		if self.followPlayerAngle then
			self.angle = -playerBody:getAngle()
		end
	end

	-- function c:getMaxMinXY(table)
	-- 	local maxX, maxY = self.transformation:transformPoint(table[1].body:getPosition())
	-- 	local minX, minY = maxX, maxY  -- Set start values as first item
	--
	-- 	for i=2, #table do
	-- 		local plx, ply = self.transformation:transformPoint(table[i].body:getPosition()) -- Get position relative to camera
	-- 		print(plx, ply, "PLTXY")
	-- 		if plx > maxX then
	-- 			maxX = plx
	-- 		elseif plx < minX then
	-- 			minX = plx
	-- 		end
	--
	-- 		if ply > maxY then
	-- 			maxY = ply
	-- 		elseif ply < minY then
	-- 			minY = ply
	-- 			print("NEW MINY", minY)
	-- 		end
	-- 	end
	--
	-- 	return maxX, maxY, minX, minY
	-- end
	--
	-- function c:lerp(a, b, dt)
	-- 	return a + (b-a)*dt
	-- end

	-- function c:getInclusiveZoom(maxX, maxY, minX, minY, borderSize)
	-- 	local extraZmFactor = 1
	-- 	local w, h = SCREEN_WIDTH, SCREEN_HEIGHT
	-- 	print(maxY, minY, "Y")
	-- 	while (maxX/extraZmFactor > w-borderSize) or (maxY/extraZmFactor > h-borderSize) or (minX/extraZmFactor < borderSize) or (minY + (extraZmFactor*minY) < borderSize) do
	-- 		--print((maxX/extraZmFactor > w-borderSize), (maxY/extraZmFactor > h-borderSize), (minX < borderSize), (minY < -borderSize))
	-- 		extraZmFactor = extraZmFactor + 0.02
	-- 	end
	-- 	self.zoom = self.zoom/extraZmFactor
	-- 	print(extraZmFactor)
	-- end

	-- function c:captureAllPl() -- all planets and players in shot
	-- 	local maxX, maxY, minX, minY = self:getMaxMinXY(bodies.planets)
	-- 	local oMaxX, oMaxY, oMinX, oMinY = maxX, maxY, minX, minY
	-- 	if #bodies.players > 1 then
	-- 		oMaxX, oMaxY, oMinX, oMinY = self:getMaxMinXY(bodies.players)
	-- 	end
	--
	-- 	maxX = math.max(maxX, oMaxX)
	-- 	maxY = math.max(maxY, oMaxY)
	-- 	minX = math.min(minX, oMinX)
	-- 	minY = math.min(minY, oMinY)
	--
	-- 	print(maxX, maxY, minX, minY, "HMM")
	-- 	self:getInclusiveZoom(maxX, maxY, minX, minY, 1)
	-- end

	function c:reset()
		self.zoom = 1
		-- self:centerOrigin()
		self.x, self.y = SCREEN_WIDTH/2, SCREEN_HEIGHT/2
		self.angle = 0
	end

	function c:changeZoom(amount)
		if self.zoom+amount >= 0.2 and self.zoom+amount <= 3 then
			self.zoom = self.zoom + amount
		end
	end

	function c:move(dt)
		if love.keyboard.isDown("j") then
			self.x = self.x - CAMERA_SPEED*dt
		end
		if love.keyboard.isDown("l") then
			self.x = self.x + CAMERA_SPEED*dt
		end
		if love.keyboard.isDown("i") then
			self.y = self.y - CAMERA_SPEED*dt
		end
		if love.keyboard.isDown("k") then
			self.y = self.y + CAMERA_SPEED*dt
		end
		-- if love.keyboard.isDown("u") then
		-- 	self.angle = self.angle - CAMERA_ROTATE_SPEED*dt
		-- end
		-- if love.keyboard.isDown("o") then
		-- 	self.angle = self.angle + CAMERA_ROTATE_SPEED*dt
		-- end
	end

	function c:updateTransform()
		self.transformation:setTransformation((-self.x)+SCREEN_WIDTH/2, (-self.y)+SCREEN_HEIGHT/2) --(SCREEN_WIDTH/2), -(SCREEN_HEIGHT/2))
		local dx, dy = self.transformation:inverseTransformPoint(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
		self.transformation:translate(dx, dy)
		self.transformation:rotate(self.angle)
		self.transformation:scale(self.zoom)
		self.transformation:translate(-dx, -dy)
	end

	function c:applyTransform()
		lg.applyTransform(self.transformation)
		--lg.applyTransform(self.angleTransform)
	end

	function c:update(dt)
		if self.followPlayer then
			if self.playerBody == nil then
				self.playerBody = getBody("player", self.playerIDToFollow, bodies.players)
				if self.playerBody ~= nil then
					self.playerBody = self.playerBody.body
				end
			elseif not self.playerBody:isDestroyed() then
				self:trackPlayer(self.playerBody)
			else
				self.playerBody = nil
			end
		end
		--self:captureAllPl()
		self:move(dt)
	end

	return c
end
