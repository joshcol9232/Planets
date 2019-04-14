use raylib::{Color, Vector2, RaylibHandle, consts};

mod planet;
use planet::{Planet, PLANET_DENSITY, TrailNode};

const G: f32 = 0.001;

struct Prediction {
	body: Planet,
	colliding: bool
}

impl Default for Prediction {
	fn default() -> Prediction {
		Prediction {
			body: Planet { is_prediction: true, ..Default::default() },
			colliding: false
		}
	}
}

impl Prediction {
	pub fn reset(&mut self, pos: Vector2, vel: Vector2, rad: f32) {
		self.body.pos = pos;
		self.body.vel = vel;
		self.body.radius = rad;
		self.colliding = false;
		self.body.trail_nodes = vec![TrailNode { pos: pos, time_created: 0.0 }];
	}

	pub fn draw(&self, rl: &RaylibHandle, time: f32) {
		self.body.draw(rl, time);
	}
}

struct App {
	rl: RaylibHandle,
	planets: Vec<Planet>,
	collided_bodies: Vec<u32>, // ID's
	pl_id_count: u32,
	mouse_click_pos: Vector2,
	last_mouse_pos: Vector2,
	paused: bool,
	planet_spawn_size: f32,
	unpaused_time: f32,

	prediction: Prediction,
}

impl App {
	pub fn new(ray: RaylibHandle) -> App {
		App {
			rl: ray,
			planets: vec![],
			collided_bodies: vec![],
			pl_id_count: 0,
			mouse_click_pos: Vector2::zero(),
			last_mouse_pos: Vector2::zero(),
			paused: true,
			planet_spawn_size: 5.0,
			unpaused_time: 0.0,

			prediction: Prediction::default()
		}
	}

	pub fn main_loop(&mut self) {
		while !self.rl.window_should_close() {
			let dt = self.rl.get_frame_time();
			self.update(dt);

			self.rl.begin_drawing();
			self.rl.clear_background(Color::BLACK);

			self.draw();

			self.rl.draw_fps(10, 10);
			self.rl.end_drawing();
		}
	}

	pub fn add_planet(&mut self, pos: Vector2, vel: Vector2, rad: f32, stationary: bool) {
		self.planets.push( planet::Planet::new(self.pl_id_count, pos, vel, rad, 0.0, stationary) );
		self.pl_id_count += 1;
	}
	
	pub fn update(&mut self, dt: f32) {
		if self.pl_id_count >= 4294967294 {
			self.pl_id_count = 0;
		}

		self.kill_dead_planets();

		self.get_input(dt);

		if !self.paused {
			self.unpaused_time += dt;
			for i in 0..self.planets.len() {   // For each planet
				for j in i..self.planets.len() {  // For every other planet
					if i != j && !self.collided_bodies.contains(&self.planets[j].id) {
						if self.check_for_collision(&self.planets[i], &self.planets[j]) && !self.collided_bodies.contains(&self.planets[i].id)  {
							self.collide(i, j);
						} else {
							let (df1, df2) = self.get_grav_force_between_two_planets(&self.planets[i], &self.planets[j]);
							self.planets[i].res_force += df1;
							self.planets[j].res_force += df2;
						}
					}
				}

				self.planets[i].update(dt, self.unpaused_time);
			}
		}
	}

	pub fn draw(&self) {
		for p in self.planets.iter() {
			p.draw(&self.rl, self.unpaused_time);
		}

		if self.rl.is_mouse_button_down(0) {
			self.rl.draw_line_ex(self.mouse_click_pos, self.rl.get_mouse_position(), 2.0, Color::GREEN);
			self.prediction.draw(&self.rl, self.unpaused_time);
		}

		self.rl.draw_text(format!("Bodies: {}", self.planets.len()).as_str(), 10, 36, 20, Color::RAYWHITE);
		self.rl.draw_text(format!("Spawn size: {}", self.planet_spawn_size).as_str(), 10, 58, 20, Color::RAYWHITE);
		self.rl.draw_text(format!("Trail nodes: {}", self.get_trail_node_total()).as_str(), 10, 80, 20, Color::RAYWHITE);
	}

	fn get_input(&mut self, dt: f32) {
		if self.rl.is_mouse_button_down(0) {
			if !self.prediction.colliding {
				self.update_prediction(dt * 12.0);
			}

			if (self.rl.get_mouse_position() - self.last_mouse_pos).length() >= 2.0 {
				self.last_mouse_pos = self.rl.get_mouse_position();
				self.prediction.reset(self.mouse_click_pos, self.mouse_click_pos - self.last_mouse_pos, self.planet_spawn_size);
			}
		}

		if self.rl.is_mouse_button_pressed(0) {
			self.mouse_click_pos = self.rl.get_mouse_position();
			self.last_mouse_pos = self.mouse_click_pos;
			self.prediction.reset(self.mouse_click_pos, Vector2::zero(), self.planet_spawn_size);
			self.paused = true;
		} else if self.rl.is_mouse_button_released(0) {
			self.add_planet(self.mouse_click_pos, self.mouse_click_pos - self.rl.get_mouse_position(), self.planet_spawn_size, false);
			self.paused = false;
			self.prediction.reset(Vector2::zero(), Vector2::zero(), self.planet_spawn_size);
		}

		if self.rl.is_mouse_button_pressed(1) {
			self.add_planet(self.rl.get_mouse_position(), Vector2::zero(), self.planet_spawn_size, true);
		}

		if self.rl.is_key_pressed(consts::KEY_UP as i32) {
			self.planet_spawn_size += 1.0;
		} else if self.rl.is_key_pressed(consts::KEY_DOWN as i32) {
			if self.planet_spawn_size >= 1.0 {
				self.planet_spawn_size -= 1.0;
			}
		}

		if self.rl.is_key_pressed(consts::KEY_P as i32) {
			self.paused = !self.paused;
		}
	}

	fn update_prediction(&mut self, dt: f32) {
		for i in 0..self.planets.len() {
			let (force, _) = self.get_grav_force_between_two_planets(&self.prediction.body, &self.planets[i]);
			self.prediction.body.res_force += force;

			self.prediction.colliding = self.check_for_collision(&self.prediction.body, &self.planets[i]);
			if self.prediction.colliding {
				break;
			}
		}

		self.prediction.body.update(dt, 0.0);
	}

	fn get_trail_node_total(&self) -> usize {
		let mut total = 0;
		for p in self.planets.iter() {
			total += p.trail_nodes.len();
		}
		total
	}

	fn kill_dead_planets(&mut self) {
		let col_bods = self.collided_bodies.clone();
		self.planets.retain(|pl| !col_bods.contains(&pl.id));
		self.collided_bodies = vec![];
	}

	pub fn check_for_collision(&self, p1: &Planet, p2: &Planet) -> bool {
		(p2.pos - p1.pos).length() <= p1.radius + p2.radius
	}

	fn collide(&mut self, p1: usize, p2: usize) {
		let total_momentum = self.planets[p1].get_momentum() + self.planets[p2].get_momentum();

		let p1_volume = self.planets[p1].mass/PLANET_DENSITY;
		let p2_volume = self.planets[p2].mass/PLANET_DENSITY;

		let new_rad = (((3.0/4.0) * (p1_volume + p2_volume))/consts::PI as f32).powf(1.0/3.0);
		let total_mass = self.planets[p1].mass + self.planets[p2].mass;

		let considerable_diference = (self.planets[p1].radius.max(self.planets[p2].radius)/self.planets[p1].radius.min(self.planets[p2].radius)).powi(3) > 2.0; // If largest more than x times more volume (proportionaly)

		self.planets.push(Planet::new(
			self.pl_id_count,
			if !considerable_diference {
				(self.planets[p1].pos + self.planets[p2].pos)/2.0
			} else if self.planets[p1].radius > self.planets[p2].radius {
				self.planets[p1].pos
			} else {
				self.planets[p2].pos
			},
			total_momentum/total_mass,
			new_rad,
			total_mass,
			if self.planets[p1].radius > self.planets[p2].radius {
				self.planets[p1].stationary
			} else {
				self.planets[p2].stationary
			}
		));

		self.pl_id_count += 1;

		self.collided_bodies.push(self.planets[p1].id);
		self.collided_bodies.push(self.planets[p2].id);
	}

	pub fn get_grav_force_between_two_planets(&self, p1: &Planet, p2: &Planet) -> (Vector2, Vector2) {   // returns force on pl1 and pl2
		let pos = p2.pos - p1.pos;
		let angle = p1.pos.angle_to(p2.pos);
		let angle2 = angle + consts::PI as f32;
		let dist = pos.length();
		if dist > p1.radius + p2.radius {
			let f_mag = (G * p1.mass * p2.mass)/(dist.powi(2));
			
			(Vector2 { x: f_mag * angle.cos(), y: f_mag * angle.sin() }, Vector2 { x: f_mag * angle2.cos(), y: f_mag * angle2.sin() })
		} else {
			(Vector2::zero(), Vector2::zero())
		}
	}

	pub fn make_square(&mut self, pos: Vector2, stat: bool, rad: f32, sep: f32, w: u32, h: u32) {
		for i in 0..w {
			for j in 0..h {
				self.add_planet(
					Vector2 { x: i as f32 * (rad + sep) * 2.0, y: j as f32 * (rad + sep) * 2.0 } + pos,
					Vector2::zero(),
					rad,
					stat
				);
			}
		}
	}
}

fn main() {
	let rl = raylib::init()
		.size(1920, 1080)
		.title("N-body")
		.msaa_4x()
		.build();

	rl.set_target_fps(144 * 2);

	let mut a = App::new(rl);
	
	a.add_planet(Vector2 { x: 740.0, y: 540.0 }, Vector2::zero(), 40.0, true);
	a.add_planet(Vector2 { x: 1180.0, y: 540.0 }, Vector2::zero(), 40.0, true);

	a.make_square(Vector2{ x: 840.0, y: 900.0 }, false, 1.0, 10.0, 12, 10);

	a.main_loop();
}
