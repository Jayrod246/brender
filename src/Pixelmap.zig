pm: c.br_pixelmap,

const Pixelmap = @This();

pub const alloc = BrPixelmapAllocate;
pub const match = BrPixelmapMatch;
pub const free = BrPixelmapFree;

extern fn BrPixelmapAllocate(@"type": c.br_uint_8, w: c.br_uint_16, h: c.br_uint_16, pixels: ?*anyopaque, flags: c_int) ?*Pixelmap;
extern fn BrPixelmapMatch(self: *Pixelmap, match_type: c.br_uint_8) ?*Pixelmap;
extern fn BrPixelmapFree(self: *Pixelmap) void;

pub inline fn getPixels(self: *Pixelmap) struct { pixels: *anyopaque, row_bytes: i16 } {
    return .{ .pixels = self.pm.pixels.?, .row_bytes = self.pm.row_bytes };
}

const br = @import("brender.zig");
const c = br.c;
