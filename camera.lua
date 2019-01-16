function Camera(x, y)
	local c = {}
	c.x    				= x
	c.y    				= y
	c.zoom = 1

	function c:reset()
		self.zoom = 1
		self:centerOrigin()
		self.x, self.y = SCREEN_WIDTH/2, SCREEN_HEIGHT/2
	end

	function c:translateXY(x, y)
		return (x-SCREEN_WIDTH/2)/self.zoom + self.x, (y-SCREEN_HEIGHT/2)/self.zoom + self.y
	end

	function c:centerOrigin()
		love.graphics.translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
	end

	function c:translateDisplay()
		love.graphics.translate(-self.x, -self.y)
	end

	function c:zoomDisplay()
		love.graphics.scale(self.zoom)
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
	end

	function c:update()
		self:move()
	end

	return c
end
