const std = @import("std");
const net = std.net;
const print = std.debug.print;

fn startserver(port: u16) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const loopback = try net.Ip4Address.parse("127.0.0.1", port);
    const localhost = net.Address{ .in = loopback };
    var server = try localhost.listen(.{ .reuse_port = true });
    defer server.deinit();
    const addr = server.listen_address;
    print("Listening on {}, ", .{addr.getPort()});

    var client = try server.accept();
    defer client.stream.close();

    print("Connection received! {} is sending data.\n", .{client.address});
    const message = try client.stream.reader().readAllAlloc(allocator, 1024);
    defer allocator.free(message);

    print("{} says {s}\n", .{ client.address, message });
}
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
                    print("Port: {d}\n", .{port.?});
                } else {
                    print("Port argument provided without a value.\n", .{});
                    port = null;
                }
            }
        }
    } else {
        print("No arguments provided.\n", .{});
        return error.NoPortProvided;
    }

    if (port) |p| {
        print("Using port: {d}\n", .{p});
    } else {
        print("No port specified, using default.\n", .{});
    }

    try startserver(port.?);
}
