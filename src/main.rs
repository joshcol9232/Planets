use raylib::{Color, Vector2, RaylibHandle, consts};

mod planet;
use planet::{Planet, PLANET_DENSITY};

const G: f32 = 0.001;

struct Prediction {
	body: Planet,
	nodes: Vec<Vector2>,
	colliding: bool
}

impl Default for Prediction {
	fn default() -> Prediction {
		Prediction {
			body: Planet::default(),
			nodes: vec![],
			colliding: false
		}
	}
}

impl Prediction {
	pub fn reset(&mut self, pos: Vector2, vel: Vector2) {
		self.body.pos = pos;
		self.body.vel = vel;
		self.colliding = false;
		self.nodes = vec![];
	}

	pub fn draw(&self, rl: &RaylibHandle) {
		for i in 0..self.nodes.len() {
			if i > 0 {
				rl.draw_line_ex(self.nodes[i-1], self.nodes[i], 1.0, Color::RED);
			}
		}
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
			paused: false,

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

	pub fn add_planet(&mut self, pos: Vector2, vel: Vector2, rad: f32) {
		self.planets.push( planet::Planet::new(self.pl_id_count, pos, vel, rad, 0.0) );
		self.pl_id_count += 1;
	}
	
	pub fn update(&mut self, dt: f32) {
		if self.pl_id_count >= 4294967294 {
			self.pl_id_count = 0;
		}

		self.kill_dead_planets();


		if self.rl.is_mouse_button_down(0) {
			if !self.prediction.colliding {
				self.update_prediction(dt * 12.0);
			}

			if (self.rl.get_mouse_position() - self.last_mouse_pos).length() > 3.0 {
				self.last_mouse_pos = self.rl.get_mouse_position();
				self.prediction.reset(self.mouse_click_pos, self.mouse_click_pos - self.last_mouse_pos);
			}
		}

		if self.rl.is_mouse_button_pressed(0) {
			self.mouse_click_pos = self.rl.get_mouse_position();
			self.last_mouse_pos = self.mouse_click_pos;
			self.prediction.reset(self.mouse_click_pos, Vector2::zero());
			self.paused = true;
		} else if self.rl.is_mouse_button_released(0) {
			self.add_planet(self.mouse_click_pos, self.mouse_click_pos - self.rl.get_mouse_position(), 5.0);
			self.paused = false;
			self.prediction.reset(Vector2::zero(), Vector2::zero());
		}

		if !self.paused {
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

				self.planets[i].update(dt);
			}
		}
	}

	pub fn draw(&self) {
		for p in self.planets.iter() {
			p.draw(&self.rl);
		}

		if self.rl.is_mouse_button_down(0) {
			self.rl.draw_line_ex(self.mouse_click_pos, self.rl.get_mouse_position(), 2.0, Color::GREEN);
			self.prediction.draw(&self.rl);
		}

		self.rl.draw_text(format!("Body num: {}", self.planets.len()).as_str(), 10, 36, 20, Color::RAYWHITE);
		self.rl.draw_text(format!("Prediction nodes: {}", self.prediction.nodes.len()).as_str(), 10, 54, 20, Color::RAYWHITE);
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

		self.prediction.body.update(dt);

		if self.prediction.nodes.len() < 2000 {
			self.prediction.nodes.push(self.prediction.body.pos);
		}
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

		self.planets.push(Planet::new(
			self.pl_id_count,
			if self.planets[p1].radius > self.planets[p2].radius + 3.0 {
				self.planets[p1].pos
			} else if (self.planets[p1].radius - self.planets[p2].radius).abs() < 3.0 {
				(self.planets[p1].pos + self.planets[p2].pos)/2.0
			} else {
				self.planets[p2].pos
			},
			total_momentum/total_mass,
			new_rad,
			total_mass,
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

	pub fn make_square(&mut self, pos: Vector2, rad: f32, sep: f32, w: u32, h: u32) {
		for i in 0..w {
			for j in 0..h {
				self.add_planet(
					Vector2 { x: i as f32 * (rad + sep) * 2.0, y: j as f32 * (rad + sep) * 2.0 } + pos,
					Vector2::zero(),
					rad
				);
			}
		}
	}
}

fn main() {
	let rl = raylib::init()
		.size(1000, 800)
		.title("N-body")
		.build();

	rl.set_target_fps(144);

	let mut a = App::new(rl);
	
	a.add_planet(Vector2 { x: 300.0, y: 310.0 }, Vector2::zero(), 50.0);
	//a.add_planet(Vector2 { x: 500.0, y: 300.0 }, Vector2::zero(), 5.0);
	//a.add_planet(Vector2 { x: 700.0, y: 300.0 }, Vector2::zero(), 5.0);
	//a.add_planet(Vector2 { x: 400.0, y: 700.0 }, Vector2::zero(), 5.0);
	//a.add_planet(Vector2 { x: 400.0, y: 500.0 }, Vector2::zero(), 5.0);
	

	//a.make_square(Vector2{ x: 200.0, y: 300.0 }, 2.0, 10.0, 20, 20);

	a.main_loop();
}
