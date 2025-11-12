const rl = @import("raylib");

width: i32,
height: i32,
force_distance: f32, // 80
velocity_factor: f32, // 0.5

const Self = @This();

pub const Species = enum(u8) {
    green = 0,
    red = 1,
    orange = 2,
    cyan = 3,

    pub fn color(self: Species) rl.Color {
        return switch (self) {
            .green => rl.Color.green,
            .red => rl.Color.red,
            .orange => rl.Color.orange,
            .cyan => rl.Color.sky_blue,
        };
    }
};

pub const default = Self{
    .width = 900,
    .height = 600,
    .force_distance = 80,
    .velocity_factor = 0.5,
};

pub fn init(width: i32, height: i32, force_distance: f32, velocity_factor: f32) Self {
    return Self{
        .width = width,
        .height = height,
        .force_distance = force_distance,
        .velocity_factor = velocity_factor,
    };
}

pub fn forceG(species1: Species, species2: Species) f32 {
    return switch (species1) {
        .green => switch (species2) {
            .green => 0.93,
            .red => -0.83,
            .orange => 0.28,
            .cyan => -0.06,
        },
        .red => switch (species2) {
            .green => -0.46,
            .red => 0.49,
            .orange => 0.28,
            .cyan => 0.64,
        },
        .orange => switch (species2) {
            .green => -0.79,
            .red => 0.23,
            .orange => -0.02,
            .cyan => -0.75,
        },
        .cyan => switch (species2) {
            .green => 0.57,
            .red => 0.95,
            .orange => -0.36,
            .cyan => 0.44,
        },
    };
}
