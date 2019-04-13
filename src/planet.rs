use raylib::{Vector2, RaylibHandle, Color, consts};

const PLANET_DENSITY: f32 = 5000.0; // kg m^-2

pub struct Planet {
	pub pos: Vector2,
	vel: Vector2,
	radius: f32,
	pub mass: f32,
	pub res_force: Vector2  // Resultant force
}

impl Planet {
	pub fn new(p: Vector2, v: Vector2, r: f32) -> Planet {
		Planet {
			pos: p,
			vel: v,
			radius: r,
			mass: Planet::get_mass(r),
			res_force: Vector2::zero()
		}
	}

	pub fn draw(&self, rl: &RaylibHandle) {
		rl.draw_circle_v(self.pos, self.radius, Color::RAYWHITE);
		self.draw_debug(rl);
	}

	pub fn update(&mut self, dt: f32) {
		self.vel += self.res_force.scale_by(dt/self.mass);  // F = ma, a = F / m, a * dt = vel increase, f * dt/mass = vel change
		self.res_force = Vector2::zero();
	
		self.pos += self.vel.scale_by(dt);
	}

	fn get_mass(radius: f32) -> f32 {  // Area is mass cause 2d
		consts::PI as f32 * (radius.powi(2)) * PLANET_DENSITY
	}

	fn draw_debug(&self, rl: &RaylibHandle) {
		rl.draw_line_ex(self.pos, (self.res_force) + self.pos, 2.0, Color::RED);
		rl.draw_line_ex(self.pos, self.vel + self.pos, 2.0, Color::LIME);
	}

}
