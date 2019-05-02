use raylib::{Color, Vector2, RaylibHandle, consts};

mod planet;
mod field_vis;
use planet::{Planet, PLANET_DENSITY, TrailNode};
use field_vis::{FieldVisual, ColourMode, get_shader_colour_mode_int};

const SCREEN_W: u32 = 1920;
const SCREEN_H: u32 = 1080;

const G: f32 = 0.001;
const FIELD_UPDATE_PERIOD: f32 = 0.05;

// Shader uniform locations:
const SHADER_BODY_NUM_LOC: i32 = 0;
const SHADER_LARGEST_RAD_LOC: i32 = 2;
const SHADER_COLOUR_MODE_LOC: i32 = 3;
const SHADER_BODIES_LOC: i32 = 4;

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
	time_multiplier: f32,

	field_v: FieldVisual,
	field_v_update_timer: f32,
	show_field: bool,
	last_largest: f32,
	last_body_num: usize,

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
			time_multiplier: 1.0,
			field_v: FieldVisual::new(&ray, 30, w, h),
			field_v_update_timer: 0.0,
			rl: ray,
			show_field: false,
			last_largest: 0.0,
			last_body_num: 0,
			pl_id_count: 0,
			mouse_click_pos: Vector2::zero(),
			last_mouse_pos: Vector2::zero(),
			paused: false,
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

				self.planets[i].update(dt * self.time_multiplier, self.unpaused_time, self.show_trails);
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

		let mut ui_col = Color::RAYWHITE;

		if self.field_v.draw_using_shader {
			match self.field_v.shader_colour_mode {
				ColourMode::WhiteAndBlack => ui_col = Color::BLACK,
				_ => (),
			}
		}

		self.rl.draw_text(format!("Bodies: {}", self.planets.len()).as_str(), 10, 36, 20, ui_col);
		self.rl.draw_text(format!("Spawn size: {}", self.planet_spawn_size).as_str(), 10, 58, 20, ui_col);
		self.rl.draw_text(format!("Time multiplier: {:.2}", self.time_multiplier).as_str(), 10, 80, 20, ui_col);
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

		if self.rl.is_key_down(consts::KEY_LEFT_SHIFT as i32) && self.rl.get_mouse_wheel_move() != 0 {
			let dm = self.rl.get_mouse_wheel_move() as f32 * 0.25;
			
			if self.time_multiplier + dm > 0.0 {
				self.time_multiplier += dm;
			}
		} else if self.rl.get_mouse_wheel_move() != 0 {
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

		if self.show_field {
			if !self.field_v.draw_using_shader && self.rl.is_key_pressed(consts::KEY_D as i32) {
				self.field_v.directional = !self.field_v.directional;
			}

			if self.rl.is_key_pressed(consts::KEY_S as i32) {
				self.field_v.draw_using_shader = !self.field_v.draw_using_shader;
			}
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
			self.rl.set_shader_value(&mut self.field_v.field_shader,
											 SHADER_BODIES_LOC + i as i32,
											 &[p.pos.x, p.pos.y, p.mass, p.radius]
			);
		}
	}

	pub fn change_field_shader_colour(&mut self, col: ColourMode) {
		if self.field_v.shader_colour_mode != col {
		  self.field_v.shader_colour_mode = col.clone();
		  self.rl.set_shader_value_i(&mut self.field_v.field_shader,
											 	SHADER_COLOUR_MODE_LOC,
											 	&[get_shader_colour_mode_int(col)]
		  );
		}
	}

	pub fn update_field_vis(&mut self) {  // In App rather than field_v because has direct access to planets array
		if self.field_v.draw_using_shader {
			// Update shader
			if self.planets.len() != self.last_body_num {
				self.rl.set_shader_value_i(&mut self.field_v.field_shader,
												 SHADER_BODY_NUM_LOC,
												 &[self.planets.len() as i32]
				);
				self.last_body_num = self.planets.len();
			}

			// Shader colour change keys
			if self.rl.is_key_pressed(consts::KEY_ONE as i32) {
				self.change_field_shader_colour(ColourMode::BlackAndYellow);
			} else if self.rl.is_key_pressed(consts::KEY_TWO as i32) {
				self.change_field_shader_colour(ColourMode::YellowAndRed);
			} else if self.rl.is_key_pressed(consts::KEY_THREE as i32) {
				self.change_field_shader_colour(ColourMode::WhiteAndBlack);
			}
			
			let largest_rad = self.get_largest_rad();

			if largest_rad != self.last_largest {
				self.rl.set_shader_value(&mut self.field_v.field_shader,
												 SHADER_LARGEST_RAD_LOC,
												 &[largest_rad]
				);
				self.last_largest = largest_rad;
			}

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

	fn get_largest_mass(&self) -> f32 {
		let mut largest = 1.0;
		for p in self.planets.iter() {
			if p.mass > largest {
				largest = p.mass;
			}
		}
		largest
	}

	fn get_largest_rad(&self) -> f32 {
		let mut largest = 0.0;
		for p in self.planets.iter() {
			if p.radius > largest {
				largest = p.radius;
			}
		}
		largest
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
		.size(SCREEN_W as i32, SCREEN_H as i32)
		.title("N-body")
		.msaa_4x()
		.build();

	rl.set_target_fps(60 * 2);

	let mut a = App::new(rl, SCREEN_W, SCREEN_H);
	
	
	a.add_planet(Vector2 { x: 400.0, y: 340.0 }, Vector2::zero(), 40.0, false);

	//a.add_planet(Vector2 { x: 740.0, y: 540.0 }, Vector2::zero(), 40.0, false);
	//a.add_planet(Vector2 { x: 1180.0, y: 540.0 }, Vector2::zero(), 40.0, true);

	//a.make_square(Vector2{ x: 840.0, y: 900.0 }, false, 1.0, 10.0, 12, 10);
	

	//a.make_square(Vector2{ x: 840.0, y: 500.0 }, false, 10.0, 20.0, 10, 10);

	a.main_loop();
}
