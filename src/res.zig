pub const ResourceClass = enum(i32) {
    prepared_vertices = c.BR_MEMORY_PREPARED_VERTICES,
    prepared_faces = c.BR_MEMORY_PREPARED_FACES,
    groups = c.BR_MEMORY_GROUPS,
};

pub const ResourceAllocOptions = struct {
    parent: ?*anyopaque = null,
    class: ResourceClass,
};

pub fn alloc(T: type, n: usize, opts: ResourceAllocOptions) ?[]T {
    const size = @sizeOf(T) * n;
    const res: [*]T = @alignCast(@ptrCast(BrResAllocate(opts.parent, size, opts.class) orelse return null));
    return res[0..n];
}

extern fn BrResAllocate(vparent: ?*anyopaque, size: c.br_size_t, res_class: ResourceClass) ?*anyopaque;

const c = @import("brender.zig").c;
