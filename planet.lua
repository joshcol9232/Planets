
function Planet(id, pos, vel, m, r)
    local p  = {}
    p.id     = id
    p.pos    = pos or Vec2(0, 0)
    p.vel    = vel or Vec2(0, 0)
    p.mass   = m
    p.radius = r

    function p:getPlanetForces(other)
        local x_force, y_force = 0, 0
        
				local angle = getAngle(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
				local dist  = getDist(self.pos.x, self.pos.y, other.pos.x, other.pos.y)

				x_force = x_force + math.cos(angle)*(1/(dist/GRAV_STRENGTH))
				y_force = y_force + math.sin(angle)*(1/(dist/GRAV_STRENGTH))

        return x_force, y_force
    end

		function p:averageForces(x_force, y_force)
			x_force = x_force / (#planets-1)
      y_force = y_force / (#planets-1)
			return x_force, y_force
		end
		
    function p:applyXForce(dx)
        self.vel.x = self.vel.x + dx
    end

    function p:applyYForce(dy)
        self.vel.y = self.vel.y + dy
    end

    function p:applyVel()
        self.pos.x = self.pos.x + self.vel.x
        self.pos.y = self.pos.y + self.vel.y
    end

		function p:checkCollision(other)
			self.colliding = false
		
			local dist = getDist(self.pos.x, self.pos.y, other.pos.x, other.pos.y) -- This could be passed into the function so that dist calculation only happens once
			if dist <= (self.radius + other.radius) then
				local friction = 0.8
				self:collide(other, friction)
				other:collide(self, friction)
			end
		end
		
		function p:collide(other, fric)
			local angle = getAngle(self.pos.x, self.pos.y, other.pos.x, other.pos.y) - math.pi
			local dx = self.vel.x
			local dy = self.vel.y
			
			self.vel.x = dx + math.cos(angle) * fric
			self.vel.y = dy + math.sin(angle) * fric
			
			self.colliding = true
		end
		
		function p:collideWindowEdge(fric)
			-- Reflect in x directions
			if self.pos.x < 0 and self.vel.x < 0 then
				self.pos.x = 0
				self.vel.x = -self.vel.x * fric
			elseif self.pos.x > WINDOW_WIDTH and self.vel.x > 0 then
				self.pos.x = WINDOW_WIDTH
				self.vel.x = -self.vel.x * fric
			end
			
			-- Reflect in y directions
			if self.pos.y < 0 and self.vel.y < 0 then
				self.pos.y = 0
				self.vel.y = -self.vel.y * fric
			elseif self.pos.y > WINDOW_HEIGHT and self.vel.y > 0 then
				self.pos.y = WINDOW_HEIGHT
				self.vel.y = -self.vel.y * fric
			end
		end
		
    function p:update()
			local x_force, y_force = 0
			for i=1, #planets do
				if i ~= self.id then
					local other = planets[i]
					x_force, y_force = self:getPlanetForces(other)
					self:checkCollision(other)
				end
			end

			local friction = 0.8
			self:collideWindowEdge(friction)
			
			x_force, y_force = self:averageForces(x_force, y_force)
			self:applyXForce(x_force)
			self:applyYForce(y_force)
			self:applyVel()
    end

    function p:draw()
			if self.colliding then
				lg.setColor({255, 0, 0})
			else
				lg.setColor({255, 255, 255})
			end
			lg.circle("line", self.pos.x, self.pos.y, self.radius)
			
			for i=1, #planets do
				if i ~= self.id then
					local other = planets[i]
					lg.setColor(100, 100, 100, 100)
					
					local angle = getAngle(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
					local dist = getDist(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
					
					local x_offset = self.pos.x + math.cos(angle)*dist
					local y_offset = self.pos.y + math.sin(angle)*dist
					lg.line(self.pos.x, self.pos.y, x_offset, y_offset)
				end
			end
    end

    table.insert(planets, p)
    return p
end
