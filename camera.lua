function Camera(x, y)
	local c = {}
	c.x    	= x
	c.y    	= y
	c.angle = 0 -- From directly up
	c.zoom = 1
	c.followPlayer = true
	c.followPlayerAngle = true
	c.playerIDToFollow = 1
	c.playerBody = nil

	function c:trackPlayer(playerBody)
		self.x, self.y = playerBody:getPosition()
		if self.followPlayerAngle then
			self.angle = -playerBody:getAngle()
		end
	end

	function c:reset()
		self.zoom = 1
		self:centerOrigin()
		self.x, self.y = SCREEN_WIDTH/2, SCREEN_HEIGHT/2
	end

	function c:translateXY(x, y)
		local nx = (x-SCREEN_WIDTH/2)/self.zoom + self.x
		local ny = (y-SCREEN_HEIGHT/2)/self.zoom + self.y

		return nx, ny
	end

	function c:centerOrigin()
		lg.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
	end

	function c:translateDisplay()
		lg.rotate(self.angle)
		lg.translate(-self.x, -self.y)
	end

	function c:zoomDisplay()
		lg.scale(self.zoom)
	end

	function c:changeZoom(amount)
		if self.zoom+amount > 0.2 and self.zoom+amount < 3 then
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
		if love.keyboard.isDown("u") then
			self.angle = self.angle + CAMERA_ROTATE_SPEED
		end
		if love.keyboard.isDown("o") then
			self.angle = self.angle - CAMERA_ROTATE_SPEED
		end
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
