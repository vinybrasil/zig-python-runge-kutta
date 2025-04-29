const std = @import("std");

fn rk4ordem(
    yinit: f64,
    xrange: *const [2]f64,
    h: f64,
    allocator: std.mem.Allocator,
    n: usize,
) anyerror![]f64 {
    const ys = try allocator.alloc(f64, n + 1);
    errdefer allocator.free(ys);

    const xs = try allocator.alloc(f64, n + 1);
    defer allocator.free(xs);

    xs[0] = xrange[0];

    ys[0] = yinit;

    var x = xrange[0];
    var y = yinit;

    var ks = [4]f64{ 0.0, 0.0, 0.0, 0.0 };

    for (1..n + 1) |i| {
        ks[0] = h * evaluate(x, y);
        ks[1] = h * evaluate(x + h * 0.5, y + ks[0] * (h * 0.5));
        ks[2] = h * evaluate(x + h * 0.5, y + ks[1] * (0.5));
        ks[3] = h * evaluate(x + h, y + ks[2]);

        y = y + (1.0 / 6.0) * (ks[0] + (2 * ks[1]) + (2 * ks[2]) + ks[3]);
        x = x + h;

        ys[i] = y;
    }

    return ys;
}

fn evaluate(x: f64, y: f64) f64 {
    const result_evaluation: f64 = 4.0 * x - 2.0 * x * y;
    return result_evaluation;
}
export fn main(
    h: c_longdouble,
    xrange_0: c_longdouble,
    xrange_1: c_longdouble,
    yinit_0: c_longdouble,
) [*]c_longdouble {
    const allocator = std.heap.page_allocator;

    var xrange = [2]f64{
        @floatCast(xrange_0),
        @floatCast(xrange_1),
    };

    const yinit: f64 = @floatCast(yinit_0);
    const h_float: f64 = @floatCast(h);
    const n: usize = @intFromFloat((xrange[1] - xrange[0]) / h_float);

    var result3: [1]c_longdouble = undefined;

    const pot: [*c]c_longdouble = @constCast(&result3);

    var result2 = allocator.alloc(c_longdouble, n + 1) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return pot;
    };

    errdefer allocator.free(result2);

    const result = rk4ordem(
        yinit,
        &xrange,
        h_float,
        allocator,
        n,
    ) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        allocator.free(result2);
        return pot;
    };

    defer allocator.free(result);

    for (result, 0..) |val, i| {
        result2[i] = @floatCast(val);
    }

    const pot2: [*c]c_longdouble = @ptrCast(result2);

    return pot2;
}

export fn free_results(ptr: [*c]c_longdouble, len: usize) void {
    const allocator = std.heap.page_allocator;
    const slice = ptr[0..len];
    allocator.free(slice);
}
