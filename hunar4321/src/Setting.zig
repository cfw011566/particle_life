const std = @import("std");
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

    pub fn size() u8 {
        return @intFromEnum(Species.cyan) + 1;
    }
};

var g_matrix: [Species.size()][Species.size()]f32 = undefined;

pub const default = Self{
    .width = 900,
    .height = 600,
    .force_distance = 80,
    .velocity_factor = 0.5,
};

pub fn init(width: i32, height: i32, force_distance: f32, velocity_factor: f32) Self {
    for (0..Species.size()) |i| {
        for (0..Species.size()) |j| {
            g_matrix[i][j] = @as(f32, @floatFromInt(rl.getRandomValue(-1000, 1000))) / 1000.0;
        }
    }
    std.log.info("g_matrix = {any}", .{g_matrix});
    return Self{
        .width = width,
        .height = height,
        .force_distance = force_distance,
        .velocity_factor = velocity_factor,
    };
}

pub fn forceG(species1: Species, species2: Species) f32 {
    const i = @intFromEnum(species1);
    const j = @intFromEnum(species2);
    return g_matrix[i][j];
}
