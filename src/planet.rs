use raylib::{Vector2, RaylibHandle, Color, consts};

pub const PLANET_DENSITY: f32 = 5000.0; // kg m^-2
const TRAIL_PLACEMENT_INTERVAL: f32 = 0.04;
const TRAIL_LIFESPAN: f32 = 1.0;

pub struct TrailNode {
	pub pos: Vector2,
	pub time_created: f32
}

pub struct Planet {
	pub id: u32,
	pub pos: Vector2,
	pub vel: Vector2,
	pub radius: f32,
	pub mass: f32,
	pub res_force: Vector2,  // Resultant force
	pub stationary: bool,
	pub is_prediction: bool,

	pub trail_nodes: Vec<TrailNode>,
	pub trail_timer: f32
}

impl Default for Planet {
	fn default() -> Planet {
		Planet {
			id: 0,
			pos: Vector2::zero(),
			vel: Vector2::zero(),
			radius: 5.0,
			mass: Planet::get_mass(2.0),
			res_force: Vector2::zero(),
			stationary: false,
			is_prediction: false,
			trail_nodes: vec![],
			trail_timer: 0.0,
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
	pub fn new(id_num: u32, p: Vector2, v: Vector2, r: f32, ma: f32, stat: bool) -> Planet {
		Planet {
			id: id_num,
			pos: p,
			vel: v,
			radius: r,
			mass: if ma == 0.0 { Planet::get_mass(r) } else { ma },
			stationary: stat,
			is_prediction: false,
			..Default::default()
		}
	}

	pub fn draw(&self, rl: &RaylibHandle, time: f32, trails: bool) {
		if trails {
			self.draw_trail(rl, time);
		}
		let col = if self.is_prediction { Color::RED } else { Color::RAYWHITE };
		
		rl.draw_circle_v(self.pos, self.radius, col);
		//self.draw_debug(rl);
	}

	pub fn update(&mut self, dt: f32, time: f32, trails: bool) {
		if !self.is_prediction {
			self.kill_dead_trails(time);
		}

		if !self.stationary {
			if trails {
				self.trail_timer += dt;
				if self.trail_timer >= TRAIL_PLACEMENT_INTERVAL {
					self.place_trail(time);
					self.trail_timer = 0.0;
				}

				let len = self.trail_nodes.len();
				if len > 0 {
					self.trail_nodes[len-1].pos = self.pos;
				}
			}

			self.vel += self.res_force.scale_by(dt/self.mass);  // F = ma, a = F / m, a * dt = vel increase, f * dt/mass = vel change
			self.res_force = Vector2::zero();
		
			self.pos += self.vel.scale_by(dt);
		}
	}

	fn draw_trail(&self, rl: &RaylibHandle, time: f32) {
		let mut col = if self.is_prediction { Color::RED } else { Color::BLUE };
		for i in 0..self.trail_nodes.len() {
			if i > 0 {
				if !self.is_prediction {
					col.a = ((1.0 - ((time - self.trail_nodes[i].time_created)/TRAIL_LIFESPAN)).powi(2) * 255.0).min(255.0) as u8;
				}
				rl.draw_line_ex(self.trail_nodes[i-1].pos, self.trail_nodes[i].pos, 2.0, col);
			}
		}
	}

	#[inline]
	fn place_trail(&mut self, time: f32) {
		//if self.vel.length() > self.radius/2.0 {
		self.trail_nodes.push(TrailNode { pos: self.pos, time_created: time });
		//}
	}

	#[inline]
	fn kill_dead_trails(&mut self, time: f32) {
		self.trail_nodes.retain(|t|time - t.time_created <= TRAIL_LIFESPAN);
	}

	#[inline]
	fn get_mass(radius: f32) -> f32 {
		4.0/3.0 * consts::PI as f32 * radius.powi(3) * PLANET_DENSITY
	}

	#[inline] 
	#[allow(dead_code)]
	fn draw_debug(&self, rl: &RaylibHandle) {
		rl.draw_line_ex(self.pos, self.vel + self.pos, 2.0, Color::LIME);
	}

	#[inline]
	pub fn get_momentum(&self) -> Vector2 {
		self.vel.scale_by(self.mass)
	}
}
