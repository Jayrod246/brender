pm: c.br_pixelmap,

const Pixelmap = @This();

pub const PixelmapAllocOptions = struct {
    format: br.PixelFormat,
    width: u16,
    height: u16,
    flags: enum(u8) { none = 0, inverted = 1 } = .none,
};

pub fn alloc2(opts: PixelmapAllocOptions) ?*Pixelmap {
    return BrPixelmapAllocate(@intFromEnum(opts.format), opts.width, opts.height, null, @intFromEnum(opts.flags));
}

pub const alloc = BrPixelmapAllocate;
pub const match = BrPixelmapMatch;
pub const free = BrPixelmapFree;

extern fn BrPixelmapAllocate(@"type": c.br_uint_8, w: c.br_uint_16, h: c.br_uint_16, pixels: ?*anyopaque, flags: c_int) ?*Pixelmap;
extern fn BrPixelmapMatch(self: *Pixelmap, match_type: c.br_uint_8) ?*Pixelmap;
extern fn BrPixelmapFree(self: *Pixelmap) void;

pub inline fn getPixels(self: *Pixelmap) struct { pixels: []u8, row_bytes: u16 } {
    const pixels: [*]u8 = @ptrCast(self.pm.pixels.?);
    const row_bytes: u16 = @intCast(self.pm.row_bytes);
    const len = @as(usize, row_bytes) * self.pm.height;
    return .{ .pixels = pixels[0..len], .row_bytes = row_bytes };
}

const br = @import("brender.zig");
const c = br.c;
