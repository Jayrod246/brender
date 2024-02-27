m: c.br_material,

const Material = @This();

// TODO: figure out defaults for these options?
pub const MaterialAllocOptions = struct {
    identifier: ?[:0]const u8,
    color: c.br_colour,
    opacity: u8,
    ka: c.br_ufraction,
    kd: c.br_ufraction,
    ks: c.br_ufraction,
    power: br.Scalar,
    flags: u32 = 0,
    map_transform: br.Matrix23 = br.Matrix23.identity,
    index_base: u8,
    index_range: u8,
    color_map: ?*br.Pixelmap = null,
    screendoor: ?*br.Pixelmap = null,
    index_shade: ?*br.Pixelmap = null,
    index_blend: ?*br.Pixelmap = null,
    prep_flags: u8 = 0,
    rptr: ?*anyopaque = null,
};

pub const add = BrMaterialAdd;

pub inline fn addAlloc(opts: MaterialAllocOptions) *Material {
    return add(alloc(opts) orelse @panic("oom"));
}

pub inline fn alloc(opts: MaterialAllocOptions) ?*Material {
    const identifier: [*c]u8 = if (opts.identifier) |tmp| @constCast(tmp) else null;
    const material = BrMaterialAllocate(identifier) orelse return null;
    material.*.m = .{
        .identifier = identifier,
        .colour = opts.color,
        .opacity = opts.opacity,
        .ka = opts.ka,
        .kd = opts.kd,
        .ks = opts.ks,
        .power = opts.power,
        .flags = opts.flags,
        .map_transform = @bitCast(opts.map_transform),
        .index_base = opts.index_base,
        .index_range = opts.index_range,
        .colour_map = @alignCast(@ptrCast(opts.color_map)),
        .screendoor = @alignCast(@ptrCast(opts.screendoor)),
        .index_shade = @alignCast(@ptrCast(opts.index_shade)),
        .index_blend = @alignCast(@ptrCast(opts.index_blend)),
        .prep_flags = opts.prep_flags,
        .rptr = opts.rptr,
    };
    return material;
}

extern fn BrMaterialAdd(material: *Material) *Material;
extern fn BrMaterialAllocate(name: [*c]u8) ?*Material;

const br = @import("brender.zig");
const c = br.c;
