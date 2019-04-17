use raylib::{Color, Vector2, RaylibHandle, consts};

mod planet;
mod field_vis;
use planet::{Planet, PLANET_DENSITY, TrailNode};
use field_vis::{FieldVisual};

const G: f32 = 0.001;
const FIELD_UPDATE_PERIOD: f32 = 0.05;

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
		self.body.draw(rl, time, true);
	}
}


struct App {
	rl: RaylibHandle,
	screen_dim: Vector2,
	planets: Vec<Planet>,
	collided_bodies: Vec<u32>, // ID's

	field_v: FieldVisual,
	field_v_update_timer: f32,
	show_field: bool,

	pl_id_count: u32,
	mouse_click_pos: Vector2,
	last_mouse_pos: Vector2,
	paused: bool,
	planet_spawn_size: f32,
	unpaused_time: f32,
	show_trails: bool,

	prediction: Prediction,
}

impl App {
	pub fn new(ray: RaylibHandle, w: u32, h: u32) -> App {
		App {
			screen_dim: Vector2 { x: w as f32, y: h as f32 },
			planets: vec![],
			collided_bodies: vec![],
			field_v: FieldVisual::new(&ray, 30, w, h),
			field_v_update_timer: 0.0,
			rl: ray,
			show_field: true,
			pl_id_count: 0,
			mouse_click_pos: Vector2::zero(),
			last_mouse_pos: Vector2::zero(),
			paused: true,
			planet_spawn_size: 5.0,
			unpaused_time: 0.0,
			show_trails: true,

			prediction: Prediction::default()
		}
	}

	pub fn main_loop(&mut self) {
		while !self.rl.window_should_close() {
			let dt = self.rl.get_frame_time();
			self.update(dt);

			self.rl.begin_drawing();
			self.rl.clear_background(Color::BLACK);
			if self.field_v.draw_using_shader && self.show_field {
				self.field_v.draw_with_shader(&self.rl, self.screen_dim.x as i32, self.screen_dim.y as i32);
			}

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
		self.field_v_update_timer += dt;
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

				self.planets[i].update(dt, self.unpaused_time, self.show_trails);
			}

			if self.show_field && (self.field_v.draw_using_shader || self.field_v_update_timer >= FIELD_UPDATE_PERIOD) {
				self.update_field_vis();
				self.field_v_update_timer = 0.0;
			}
		}
	}

	pub fn draw(&self) {
		if self.show_field && !self.field_v.draw_using_shader {
			self.field_v.draw(&self.rl)
		}

		for p in self.planets.iter() {
			p.draw(&self.rl, self.unpaused_time, self.show_trails);
		}

		if self.rl.is_mouse_button_down(0) {
			self.rl.draw_line_ex(self.mouse_click_pos, self.rl.get_mouse_position(), 2.0, Color::GREEN);
			self.prediction.draw(&self.rl, self.unpaused_time);
		}

		self.rl.draw_text(format!("Bodies: {}", self.planets.len()).as_str(), 10, 36, 20, Color::RAYWHITE);
		self.rl.draw_text(format!("Spawn size: {}", self.planet_spawn_size).as_str(), 10, 58, 20, Color::RAYWHITE);
		//self.rl.draw_text(format!("Total mass: {}", self.get_total_mass()).as_str(), 10, 80, 20, Color::RAYWHITE);
		//self.rl.draw_text(format!("Trail nodes: {}", self.get_trail_node_total()).as_str(), 10, 96, 20, Color::RAYWHITE);
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
			self.make_square(self.rl.get_mouse_position(), false, self.planet_spawn_size, 5.0, 10, 10);
		}

		if self.rl.is_mouse_button_pressed(2) {
			self.add_planet(self.rl.get_mouse_position(), Vector2::zero(), self.planet_spawn_size, true);
		}

		if self.rl.get_mouse_wheel_move() != 0 {
			let dm = self.rl.get_mouse_wheel_move();

			if dm > 0 {
				self.planet_spawn_size += 1.0;
			} else if self.planet_spawn_size > 1.0 {
				self.planet_spawn_size -= 1.0;
			}
		}

		if self.rl.is_key_pressed(consts::KEY_P as i32) {
			self.paused = !self.paused;
		}

		if self.rl.is_key_pressed(consts::KEY_F as i32) {
			self.show_field = !self.show_field;
		}

		if self.rl.is_key_pressed(consts::KEY_T as i32) {
			self.show_trails = !self.show_trails;
		}

		if self.rl.is_key_pressed(consts::KEY_R as i32) {
			self.reset();
		}

		if self.show_field && self.rl.is_key_pressed(consts::KEY_D as i32) {
			self.field_v.directional = !self.field_v.directional;
		}
	}

	#[inline]
	fn reset(&mut self) {
		self.planets = vec![];
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

		self.prediction.body.update(dt, 0.0, true);
	}

	#[allow(dead_code)]
	fn get_trail_node_total(&self) -> usize {
		let mut total = 0;
		for p in self.planets.iter() {
			total += p.trail_nodes.len();
		}
		total
	}

	#[allow(dead_code)]
	fn get_total_mass(&self) -> f32 {
		let mut total = 0.0;
		for p in self.planets.iter() {
			total += p.mass;
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

		let (big, small) = if self.planets[p1].radius > self.planets[p2].radius { (p1, p2) } else if self.planets[p1].radius < self.planets[p2].radius { (p2, p1) } else { (p1, p2) };

		let considerable_diference = (self.planets[big].radius/self.planets[small].radius).powi(3) > 2.0; // If largest more than x times more volume (proportionaly)

		self.planets[big].pos = if !considerable_diference {
											(self.planets[big].pos + self.planets[small].pos)/2.0
										} else {
											self.planets[big].pos
										};

		self.planets[big].vel = total_momentum/total_mass;
		self.planets[big].radius = new_rad;
		self.planets[big].mass = total_mass;

		self.collided_bodies.push(self.planets[small].id);
	}

	pub fn get_grav_force_between_two_planets(&self, p1: &Planet, p2: &Planet) -> (Vector2, Vector2) {   // returns force on pl1 and pl2
		let dist = (p2.pos - p1.pos).length();
		let angle = p1.pos.angle_to(p2.pos);

		if dist > p1.radius + p2.radius {  // If colliding then don't bother
			let vec1 = get_grav_force(dist, angle, p1.mass, p2.mass);
			(vec1, Vector2 { x: -vec1.x, y: -vec1.y })
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

	fn send_planets_to_shader(&mut self) {
		for (i, p) in self.planets.iter().enumerate() {
			let bod_loc = self.rl.get_shader_location(&self.field_v.field_shader, format!("bodies[{}]", i).as_str());

			self.rl.set_shader_value(&mut self.field_v.field_shader,
											 bod_loc,
											 &[p.pos.x, p.pos.y, p.mass]
			);
		}
	}

	pub fn update_field_vis(&mut self) {  // Doesn't need time
		if self.field_v.draw_using_shader {
			// Update shader
			let body_num = self.rl.get_shader_location(&self.field_v.field_shader, "body_num");
			self.rl.set_shader_value_i(&mut self.field_v.field_shader,
											 body_num,
											 &[self.planets.len() as i32]
			);

			self.send_planets_to_shader();

		} else {
			for n in self.field_v.nodes.iter_mut() {
				n.force = Vector2::zero();
				for p in self.planets.iter() {
					let dist = (p.pos - n.pos).length();
					if dist > p.radius {  // If inside then don't bother
						n.force += get_grav_force(dist, n.pos.angle_to(p.pos), 1.0, p.mass);
					}
				}
			}
			self.field_v.update_scales();
		}
	}
}

#[inline]
fn grav_equ(m1: f32, m2: f32, distance: f32) -> f32 { // gets magnitude of gravitational force
	(G * m1 * m2)/(distance.powi(2))
}

#[inline]
fn get_grav_force(dist: f32, angle: f32, m1: f32, m2: f32) -> Vector2 {
	let f_mag = grav_equ(m1, m2, dist);
	Vector2 { x: f_mag * angle.cos(), y: f_mag * angle.sin() }
}

fn main() {
	let rl = raylib::init()
		.size(1000, 800)
		.title("N-body")
		.msaa_4x()
		.build();

	rl.set_target_fps(144);

	let mut a = App::new(rl, 1000, 800);
	
	
	a.add_planet(Vector2 { x: 740.0, y: 540.0 }, Vector2::zero(), 40.0, false);
	//a.add_planet(Vector2 { x: 1180.0, y: 540.0 }, Vector2::zero(), 40.0, true);

	//a.make_square(Vector2{ x: 840.0, y: 900.0 }, false, 1.0, 10.0, 12, 10);
	

	//a.make_square(Vector2{ x: 840.0, y: 500.0 }, false, 10.0, 20.0, 10, 10);

	a.main_loop();
}
