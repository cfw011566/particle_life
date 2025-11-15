const std = @import("std");
const rl = @import("raylib");
const Atom = @import("Atom.zig");

const NUM_ATOMS = 3000;
const DELTA_TIME = 0.02;
const FRICTION_HALF_LIFE = 0.04;
const FRICTION_FACTOR = std.math.pow(f32, 0.5, DELTA_TIME / FRICTION_HALF_LIFE);
const R_MAX = 0.1;
const NUM_COLOR = 6;

var matrix: [NUM_COLOR][NUM_COLOR]f32 = undefined;
var atoms: [NUM_ATOMS]Atom = undefined;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 1000;

    std.log.info("friction factor = {d}", .{FRICTION_FACTOR});
    const rand = std.crypto.random;
    for (0..NUM_COLOR) |i| {
        for (0..NUM_COLOR) |j| {
            matrix[i][j] = rand.float(f32) * 2.0 - 1.0;
        }
    }
    std.log.info("matrix = {any}", .{matrix});
    for (0..NUM_ATOMS) |i| {
        const x = rand.float(f32);
        const y = rand.float(f32);
        const color: usize = @intCast(rand.intRangeLessThan(usize, 0, NUM_COLOR));
        atoms[i] = Atom.init(x, y, color);
    }

    rl.initWindow(screenWidth, screenHeight, "particle life by tom-mohr");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(10); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // update velocities
        for (0..NUM_ATOMS) |i| {
            var total_force = rl.Vector2.zero();
            for (0..NUM_ATOMS) |j| {
                if (i == j) continue;
                var r_v = rl.math.vector2Subtract(atoms[i].position, atoms[j].position);
                const r = rl.math.vector2Length(r_v);
                if (r > 0 and r < R_MAX) {
                    const ci = atoms[i].color;
                    const cj = atoms[j].color;
                    const f = force(r / R_MAX, matrix[ci][cj]);
                    r_v = rl.math.vector2Scale(r_v, f / r);
                    total_force = rl.math.vector2Add(total_force, r_v);
                }
            }
            total_force = rl.math.vector2Scale(total_force, R_MAX);
            const delta_velocity = rl.math.vector2Scale(total_force, DELTA_TIME);
            atoms[i].velocity = rl.math.vector2Scale(atoms[i].velocity, FRICTION_FACTOR);
            atoms[i].velocity = rl.math.vector2Add(atoms[i].velocity, delta_velocity);
        }

        // update positions
        for (&atoms) |*atom| {
            atom.position = rl.math.vector2Add(atom.position, atom.velocity);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        for (atoms) |atom| {
            const x: i32 = @intFromFloat(atom.position.x * screenWidth);
            const y: i32 = @intFromFloat(atom.position.y * screenHeight);
            const hue = 360.0 * @as(f32, @floatFromInt(atom.color)) / NUM_COLOR;
            const color = rl.colorFromHSV(hue, 1.0, 1.0);
            rl.drawCircle(x, y, 1.0, color);
        }
        //----------------------------------------------------------------------------------
    }
}

pub fn force(r: f32, a: f32) f32 {
    const beta = 0.3;
    if (r < beta) {
        return r / beta - 1.0;
    } else if (beta < r and r < 1) {
        return a * (1 - @abs(2 * r - 1 - beta) / (1 - beta));
    } else {
        return 0;
    }
}
