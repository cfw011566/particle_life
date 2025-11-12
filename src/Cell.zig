const rl = @import("raylib");
const Setting = @import("Setting.zig");

position: rl.Vector2,
velocity: rl.Vector2,
species: Setting.Species,
radius: f32,

const Self = @This();

pub fn init(x: f32, y: f32, species: Setting.Species, radius: f32) Self {
    return Self{
        .position = rl.Vector2{ .x = x, .y = y },
        .velocity = rl.math.vector2Zero(),
        .species = species,
        .radius = radius,
    };
}

pub fn draw(self: Self) void {
    rl.drawCircleV(self.position, self.radius, self.species.color());

    // const rect = rl.Rectangle{ .x = self.position.x, .y = self.position.y, .height = self.radius * 2, .width = self.radius * 2 };
    // rl.drawRectangleRounded(rect, self.radius, 20, self.color);
}

pub fn update(self: *Self, another: Self, setting: Setting) void {
    var fx: f32 = 0;
    var fy: f32 = 0;
    const dx = self.position.x - another.position.x;
    const dy = self.position.y - another.position.y;
    const distance = rl.math.vector2Distance(self.position, another.position);
    if (distance > 0 and distance < setting.force_distance) {
        const g = Setting.forceG(self.species, another.species);
        const force = (g * 1) / distance;
        fx += force * dx;
        fy += force * dy;
    }
    self.velocity.x = (self.velocity.x + fx) * setting.velocity_factor;
    self.velocity.y = (self.velocity.y + fy) * setting.velocity_factor;
    self.position = rl.math.vector2Add(self.position, self.velocity);
    if (self.position.x <= 0 or self.position.x >= @as(f32, @floatFromInt(setting.width))) {
        self.velocity.x *= -1;
    }
    if (self.position.y <= 0 or self.position.y >= @as(f32, @floatFromInt(setting.height))) {
        self.velocity.y *= -1;
    }
}
