use raylib::{Color, Vector2, RaylibHandle, consts};

mod planet;

const G: f32 = 0.1;

struct App {
	rl: RaylibHandle,
	planets: Vec<planet::Planet>,
}

impl App {
	pub fn new(ray: RaylibHandle) -> App {
		App {
			rl: ray,
			planets: vec![],
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
	
	pub fn update(&mut self, dt: f32) {
		for i in 0..self.planets.len() {   // For each planet
			for j in i..self.planets.len() {  // For every other planet
				if i != j {
					println!("i, j: {} {}", i, j);
					let (df1, df2) = self.get_grav_force_between_two_planets(i, j);
					self.planets[i].res_force += df1;
					self.planets[j].res_force += df2;

					println!("Egg: {} {}", df1.x, df2.x);
				}
			}

			self.planets[i].update(dt);
		}
	}

	pub fn draw(&self) {
		for p in self.planets.iter() {
			p.draw(&self.rl);
		}
	}

	fn get_grav_force_between_two_planets(&self, i1: usize, i2: usize) -> (Vector2, Vector2) {   // returns force on pl1 and pl2
		let pos = self.planets[i2].pos - self.planets[i1].pos;
		let angle = self.planets[i1].pos.angle_to(self.planets[i2].pos);
		let angle2 = angle + consts::PI as f32;
		let f_mag = (G * self.planets[i1].mass * self.planets[i2].mass)/(pos.length().powi(2));
		
		(Vector2 { x: f_mag * angle.cos(), y: f_mag * angle.sin() }, Vector2 { x: f_mag * angle2.cos(), y: f_mag * angle2.sin() })
	}

	pub fn add_planet(&mut self, pos: Vector2, vel: Vector2, rad: f32) {
		self.planets.push( planet::Planet::new(pos, vel, rad) );
	}
}


fn main() {
	let rl = raylib::init()
		.size(1000, 800)
		.title("N-body")
		.build();

	rl.set_target_fps(144);

	let mut a = App::new(rl);
	a.add_planet(Vector2 { x: 300.0, y: 310.0 }, Vector2 { x: 10.0, y: 10.0 }, 5.0);
	a.add_planet(Vector2 { x: 500.0, y: 300.0 }, Vector2::zero(), 5.0);
	a.add_planet(Vector2 { x: 700.0, y: 300.0 }, Vector2::zero(), 5.0);
	a.add_planet(Vector2 { x: 400.0, y: 700.0 }, Vector2::zero(), 5.0);
	a.add_planet(Vector2 { x: 400.0, y: 500.0 }, Vector2::zero(), 5.0);

	a.main_loop();
}
