
function Planet(id, pos, vel, r, d)
    local p    = {}
    p.id       = id
    p.pos      = pos or Vec2(0, 0)
    p.vel      = vel or Vec2(0, 0)
    p.radius   = r
    p.density  = d

    p.volume 	 = (4/3) * PI * (p.radius^3)
    p.mass 		 = p.density * p.volume
    print(p.radius, "Mass:", p.mass)
    p.momentum = Vec2((p.mass * p.vel.x), (p.mass * p.vel.y))

    function p:getGravMomentum(other)
      local x_force, y_force = 0, 0
        
			local angle = getAngle(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
			local dist  = getDist(self.pos.x, self.pos.y, other.pos.x, other.pos.y)

			local force = (GCONST * self.mass * other.mass)/(dist^2)

			x_force = x_force + math.cos(angle) * force
			y_force = y_force + math.sin(angle) * force

      return (x_force*deltaT), (y_force*deltaT) -- Force = change in momentum / time, so Force * Time = Momentum
    end

    function p:applyVel()
      self.pos.x = self.pos.x + self.vel.x
      self.pos.y = self.pos.y + self.vel.y
    end

    function p:applyMomentum(dxMomentum, dyMomentum)
    	self.momentum.x, self.momentum.y = self.momentum.x + dxMomentum, self.momentum.y + dyMomentum
    	self.vel.x, self.vel.y = self.momentum.x/self.mass, self.momentum.y/self.mass   -- Also set velocity
    end

		function p:checkCollision(other)
			self.colliding = false
		
			local dist = getDist(self.pos.x, self.pos.y, other.pos.x, other.pos.y) -- This could be passed into the function so that dist calculation only happens once
			if dist <= (self.radius + other.radius) then
				self:collide(other)--, friction)
				--other:collide(self)--, friction)
			end
		end
		
		function p:collide(other)
			--local momAngle = getAngle(self.momentum.x, self.momentum.y, other.momentum.x, other.momentum.y)
			local hitAngle = getAngle(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
			print("Before collision:", self.momentum.x, self.momentum.y, other.momentum.x, other.momentum.y)
			self.momentum.x, self.momentum.y, other.momentum.x, other.momentum.y = math.sin(hitAngle)*other.momentum.x, math.cos(hitAngle)*other.momentum.y, math.sin(hitAngle)*self.momentum.x, math.sin(hitAngle)*self.momentum.y
			print("After collision:", self.momentum.x, self.momentum.y, other.momentum.x, other.momentum.y)
			self.colliding = true
		end
		
		function p:collideWindowEdge()--fric)
			-- Reflect in x directions
			if self.pos.x < 0 and self.momentum.x < 0 then
				self.pos.x = 0
				self.momentum.x = -self.momentum.x-- * fric
			elseif self.pos.x > WINDOW_WIDTH and self.momentum.x > 0 then
				self.pos.x = WINDOW_WIDTH
				self.momentum.x = -self.momentum.x-- * fric
			end
			
			-- Reflect in y directions
			if self.pos.y < 0 and self.momentum.y < 0 then
				self.pos.y = 0
				self.momentum.y = -self.momentum.y-- * fric
			elseif self.pos.y > WINDOW_HEIGHT and self.momentum.y > 0 then
				self.pos.y = WINDOW_HEIGHT
				self.momentum.y = -self.momentum.y-- * fric
			end
		end

    function p:update()
    	local dxMomentum, dyMomentum = 0, 0
			for i=1, #planets do
				if i ~= self.id then
					local other = planets[i]
					dxMomentum, dyMomentum = self:getGravMomentum(other)  -- Change in momentum due to gravity of other planets.
					self:checkCollision(other)
				end
			end
			--print()

			--local friction = 0.8
			--self:collideWindowEdge()--friction)
			
			self:applyMomentum(dxMomentum, dyMomentum)
			--print(self.id, "Momentum:", self.momentum.x, self.momentum.y)
			self:applyVel()
    end

    function p:draw()
			if self.colliding then
				lg.setColor({255, 0, 0})
			else
				lg.setColor({255, 255, 255})
			end
			lg.circle("line", self.pos.x, self.pos.y, self.radius)
			lg.print(self.id, self.pos.x, self.pos.y)
			lg.print(tostring(math.floor(self.momentum.x))..", "..tostring(math.floor(self.momentum.y)), self.pos.x-30, self.pos.y-30)
			--lg.line(self.pos.x, self.pos.y, self.momentum.x, self.momentum.y)
			
			for i=1, #planets do
				if i ~= self.id then
					local other = planets[i]
					lg.setColor(100, 100, 100, 100)
					
					local angle = getAngle(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
					local dist = getDist(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
					
					local x_offset = self.pos.x + math.cos(angle)*dist
					local y_offset = self.pos.y + math.sin(angle)*dist
					--lg.line(self.pos.x, self.pos.y, x_offset, y_offset)
				end
			end
    end

    table.insert(planets, p)
    return p
end
