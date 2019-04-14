use raylib::{Vector2, RaylibHandle, Color, consts};

pub const PLANET_DENSITY: f32 = 5000.0; // kg m^-2

pub struct Planet {
	pub id: u32,
	pub pos: Vector2,
	pub vel: Vector2,
	pub radius: f32,
	pub mass: f32,
	pub res_force: Vector2,  // Resultant force

	pub has_merged: bool,  // For removing
}

impl Default for Planet {
	fn default() -> Planet {
		Planet {
			id: 0,
			pos: Vector2::zero(),
			vel: Vector2::zero(),
			radius: 2.0,
			mass: Planet::get_mass(2.0),
			res_force: Vector2::zero(),
			has_merged: false
		}
	}
}

impl PartialEq for Planet {
	fn eq(&self, other: &Planet) -> bool {
		self.id == other.id
	}
}

impl Eq for Planet {}

impl Planet {
	pub fn new(id_num: u32, p: Vector2, v: Vector2, r: f32, ma: f32) -> Planet {
		Planet {
			id: id_num,
			pos: p,
			vel: v,
			radius: r,
			mass: if ma == 0.0 { Planet::get_mass(r) } else { ma },
			..Default::default()
		}
	}

	pub fn draw(&self, rl: &RaylibHandle) {
		rl.draw_circle_v(self.pos, self.radius, Color::RAYWHITE);
		//self.draw_debug(rl);
	}

	pub fn update(&mut self, dt: f32) {
		self.vel += self.res_force.scale_by(dt/self.mass);  // F = ma, a = F / m, a * dt = vel increase, f * dt/mass = vel change
		self.res_force = Vector2::zero();
	
		self.pos += self.vel.scale_by(dt);
	}

	fn get_mass(radius: f32) -> f32 {
		4.0/3.0 * consts::PI as f32 * radius.powi(3) * PLANET_DENSITY
	}

	fn draw_debug(&self, rl: &RaylibHandle) {
		rl.draw_line_ex(self.pos, self.vel + self.pos, 2.0, Color::LIME);
	}

	pub fn get_momentum(&self) -> Vector2 {
		self.vel.scale_by(self.mass)
	}
}
