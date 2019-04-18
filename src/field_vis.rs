use raylib::{Vector2, RaylibHandle, Color, Shader};

pub struct FieldNode {
	pub pos: Vector2,
	pub force: Vector2,
	col: Color,
	normalized: Vector2
}

pub struct FieldVisual {  // Shows field lines
	pub nodes: Vec<FieldNode>,
	max_line_len: f32,
	pub directional: bool,
	pub field_shader: Shader,
	pub draw_using_shader: bool
}

impl FieldVisual {
	pub fn new(rl: &RaylibHandle, spacing: u32, w: u32, h: u32) -> FieldVisual {
		let mut f = FieldVisual {
			nodes: FieldVisual::generate_nodes(spacing, w, h),
			max_line_len: spacing as f32/2.0,
			directional: false,
			field_shader: rl.load_shader("", "src/field_shader.fs"),
			draw_using_shader: false
		};

		let scrn_height = rl.get_shader_location(&f.field_shader, "screen_height");
		rl.set_shader_value_i(&mut f.field_shader,
										 scrn_height,
										 &[h as i32]
		);

		f
	}

	pub fn draw(&self, rl: &RaylibHandle) {
		for n in self.nodes.iter() {
			rl.draw_pixel_v(n.pos, n.col);
			if self.directional {
				rl.draw_line_ex(n.pos, ((n.normalized/n.normalized.length()) * self.max_line_len) + n.pos, 2.0, n.col);
			} else {
				let draw_line = n.normalized * self.max_line_len;
				if draw_line.length() > 1.0 {
					rl.draw_line_ex(n.pos, draw_line + n.pos, 2.0, n.col);
				}
			}
		}
	}

	pub fn draw_with_shader(&self, rl: &RaylibHandle, w: i32, h: i32) {
		rl.begin_shader_mode(&self.field_shader);
		rl.draw_rectangle(0, 0, w, h, Color::WHITE);
		rl.end_shader_mode();
	}

	pub fn update_scales(&mut self) {
		let largest = self.get_max_force_magnitude();
		for n in self.nodes.iter_mut() {
			n.normalized = n.force/largest;
			n.col = FieldVisual::get_line_color(n.normalized.length().powf(1.0/3.0));
		}
	}

	fn get_line_color(norm_val: f32) -> Color {
		Color {
			r: (255.0/norm_val).min(255.0) as u8,
			g: (255.0 - (255.0 * norm_val)) as u8,
			b: 0,
			a: 255
		}
	}

	fn get_max_force_magnitude(&self) -> f32 {
		let mut largest = 0.0;
		for n in self.nodes.iter() {
			let mag = n.force.length();
			if mag > largest {
				largest = mag;
			}
		}

		largest
	}

	fn generate_nodes(spacing: u32, w: u32, h: u32) -> Vec<FieldNode> { // w and h is width and height of field
		let mut out: Vec<FieldNode> = vec![];

		let num_hor = (w as f32/spacing as f32).ceil() as u32;
		let num_ver = (h as f32/spacing as f32).ceil() as u32;

		for i in 0..num_hor {
			for j in 0..num_ver {
				let offset = spacing as f32/2.0;
				out.push(FieldNode {
					pos: Vector2 { x: (i as f32 * spacing as f32) + offset, y: (j as f32 * spacing as f32) + offset },
					force: Vector2::zero(),
					col: Color::RED,
					normalized: Vector2::zero()
				});
			}
		}

		out
	}
}
