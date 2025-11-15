const std = @import("std");
const rl = @import("raylib");

position: rl.Vector2,
velocity: rl.Vector2,
color: usize,

const Self = @This();

pub fn init(x: f32, y: f32, color: usize) Self {
    return Self{
        .position = rl.Vector2.init(x, y),
        .velocity = rl.Vector2.zero(),
        .color = color,
    };
}
