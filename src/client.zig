const std = @import("std");
const net = std.net;
const print = std.debug.print;
pub fn main() !void {
    // Collect the command line arguments
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    // Defer the free of the arguments
    defer std.process.argsFree(std.heap.page_allocator, args);
    //Initialize the variables for storing the port
    var port: ?u16 = null;

    if (args.len > 1) {
        for (args, 0..) |arg, index| {
            if (std.mem.eql(u8, arg, "--port")) {
                if (index + 1 < args.len and !std.mem.eql(u8, args[index + 1], "")) {
                    port = try std.fmt.parseInt(u16, args[index + 1], 10);
                    std.debug.print("Port: {d}\n", .{port.?});
                } else {
                    std.debug.print("Port argument provided without a value.\n", .{});
                    port = null;
                }
            }
        }
    } else {
        std.debug.print("No arguments provided.\n", .{});
        return error.NoPortProvided;
    }

    if (port) |p| {
        print("Using port: {d}\n", .{p});
    } else {
        print("No port specified, using default.\n", .{});
    }
    // Main server
    const peer = try net.Address.parseIp4("127.0.0.1", port.?);
    // Connect to peer
    const stream = try net.tcpConnectToAddress(peer);
    defer stream.close();
    print("Connecting to {}", .{peer});
    const data = "hello zig";
    var writer = stream.writer();
    const size = try writer.write(data);
    print("Sending '{s}' to peer, total written: {d} bytes\n", .{ data, size });
}
