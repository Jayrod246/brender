m: c.br_model,

const Model = @This();

pub const ModelFlags = enum(u16) {
    preprepared = c.BR_MODF_PREPREPARED,
};

pub const alloc = BrModelAllocate;
pub const load = BrModelLoad;
pub const add = BrModelAdd;

pub inline fn getBuffers(self: *Model) struct { vertices: []br.Vertex, faces: []br.Face } {
    return .{ .vertices = self.m.vertices[0..self.m.nvertices], .faces = self.m.faces[0..self.m.nfaces] };
}

extern fn BrModelAllocate(name: [*c]const u8, num_vertices: c_int, num_faces: c_int) ?*Model;
extern fn BrModelLoad(filename: [*c]const u8) ?*Model;
extern fn BrModelAdd(self: *Model) *Model;

const br = @import("brender.zig");
const c = br.c;
