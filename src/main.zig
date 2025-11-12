const std = @import("std");
const rl = @import("raylib");
const Cell = @import("Cell.zig");
const Setting = @import("Setting.zig");

const NUM_ATOM = 3000;
const CELL_RADIUS = 1;

const screen_width = 1200;
const screen_height = 900;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    var atoms: [NUM_ATOM]Cell = undefined;
    for (0..atoms.len) |i| {
        const x: f32 = @floatFromInt(rl.getRandomValue(10 * CELL_RADIUS, screen_width - 10 * CELL_RADIUS));
        const y: f32 = @floatFromInt(rl.getRandomValue(10 * CELL_RADIUS, screen_height - 10 * CELL_RADIUS));
        const species: Setting.Species = @enumFromInt(rl.getRandomValue(0, @intFromEnum(Setting.Species.cyan)));
        atoms[i] = Cell.init(x, y, species, CELL_RADIUS);
    }

    const setting = Setting.init(screen_width, screen_height, 80, 0.5);

    rl.initWindow(screen_width, screen_height, "particle life");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        for (0..NUM_ATOM) |i| {
            for (0..NUM_ATOM) |j| {
                if (i == j) {
                    continue;
                }
                atoms[i].update(atoms[j], setting);
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);

        for (atoms, 0..) |atom, i| {
            _ = i;
            atom.draw();
        }
        //----------------------------------------------------------------------------------
    }
}

pub fn rule(cell1: *Cell, cell2: *Cell, g: f32) Cell {
    var cell = cell1.*;
    var fx: f32 = 0;
    var fy: f32 = 0;
    const dx = cell1.position.x - cell2.position.x;
    const dy = cell1.position.y - cell2.position.y;
    const distance = rl.math.vector2Distance(cell1.position, cell2.position);
    // std.log.info("({d},{d}) ({d},{d})", .{ cell1.position.x, cell1.position.y, cell2.position.x, cell2.position.y });
    // std.log.info("distance = {d}", .{distance});
    if (distance > 0 and distance < 800) {
        // const force = (g * cell1.radius * cell2.radius) / distance;
        const force = (g * 1) / distance;
        //std.log.info("F = {d}", .{force});
        fx += force * dx;
        fy += force * dy;
    }
    cell.velocity.x = (cell.velocity.x + fx) * 1.0;
    cell.velocity.y = (cell.velocity.y + fy) * 1.0;
    cell.position = rl.math.vector2Add(cell.position, cell.velocity);
    // std.log.info("p = ({d},{d}) v = ({d},{d})", .{ cell1.position.x, cell1.position.y, cell1.velocity.x, cell1.velocity.y });
    if (cell.position.x <= 0 or cell.position.x >= screen_width) {
        cell.velocity.x *= -1;
    }
    if (cell.position.y <= 0 or cell.position.y >= screen_height) {
        cell.velocity.y *= -1;
    }
    return cell;
}
