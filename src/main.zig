const std = @import("std");
const net = std.net;
pub fn main() !void {
    // Collect the command line arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    // Defer the free of the arguments
    defer std.process.argsFree(std.heap.page_allocator, args);
    //Initialize the variables for storing the port
    var port: ?u32 = null;

    if (args.len > 1) {
        for (args, 0..) |arg, index| {
            std.debug.print("Argument: {s}\n", .{arg});
            if (std.mem.eql(u8, arg, "--port")) {
                if (index + 1 < args.len and !std.mem.eql(u8, args[index + 1], "")) {
                    port = try std.fmt.parseInt(u32, args[index + 1], 10);
                    std.debug.print("Port: {d}\n", .{port.?});
                } else {
                    std.debug.print("Port argument provided without a value.\n", .{});
                    port = null;
                }
            }
        }
    } else {
        std.debug.print("No arguments provided.\n", .{});
    }

    if (port) |p| {
        std.debug.print("Using port: {d}\n", .{p});
    } else {
        std.debug.print("No port specified, using default.\n", .{});
    }
}
