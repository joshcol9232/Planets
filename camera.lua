function Camera(x, y)
	local c = {}
	c.x    	= x
	c.y    	= y
	c.angle = 0 -- From directly up
	c.zoom = 1
	c.followPlayer = true
	--c.followPlayerAngle = true
	c.playerIDToFollow = 1
	c.playerBody = nil
	c.transformation = love.math.newTransform(-c.x, -c.y, c.angle, c.zoom, c.zoom, 0, 0, 0, 0)
	c.angleTransform = love.math.newTransform(-SCREEN_WIDTH/2, -SCREEN_HEIGHT/2, c.angle)

	function c:inverseTransformPoint(x, y)
		return self.transformation:inverseTransformPoint(x, y)
	end

	function c:trackPlayer(playerBody)
		self.x, self.y = playerBody:getPosition()
		self.angle = -playerBody:getAngle()
	end

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

	function c:move()
		if love.keyboard.isDown("j") then
			self.x = self.x - CAMERA_SPEED
		end
		if love.keyboard.isDown("l") then
			self.x = self.x + CAMERA_SPEED
		end
		if love.keyboard.isDown("i") then
			self.y = self.y - CAMERA_SPEED
		end
		if love.keyboard.isDown("k") then
			self.y = self.y + CAMERA_SPEED
		end
		-- if love.keyboard.isDown("u") then
		-- 	self.angle = self.angle - CAMERA_ROTATE_SPEED
		-- end
		-- if love.keyboard.isDown("o") then
		-- 	self.angle = self.angle + CAMERA_ROTATE_SPEED
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

	function c:update()
		if self.followPlayer then
			if self.playerBody == nil then
				self.playerBody = getBody("player", self.playerIDToFollow, bodies.players)
				if self.playerBody ~= nil then
					self.playerBody = self.playerBody.body
				end
			else
				self:trackPlayer(self.playerBody)
			end
		end
		self:move()
	end

	return c
end
