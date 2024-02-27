pub const c = @cImport({
    @cInclude("brender.h");
});

pub const Pixelmap = @import("Pixelmap.zig");
pub const res = @import("res.zig");
pub const Material = @import("Material.zig");
pub const Model = @import("Model.zig");
pub const Actor = @import("Actor.zig");

pub const LightType = union(enum) {
    directional: struct {
        color: RGB = RGB.white,
        constant_attenuation: Scalar = scalar(1.0),
    },
    point: struct {
        color: RGB = RGB.white,
        constant_attenuation: Scalar = scalar(1.0),
        linear_attenuation: Scalar = 0,
        quadratic_attenuation: Scalar = 0,
    },
    spot: struct {
        color: RGB = RGB.white,
        constant_attenuation: Scalar = scalar(1.0),
        linear_attenuation: Scalar = 0,
        quadratic_attenuation: Scalar = 0,
        outer_cone: c.br_angle = degrees(15.0),
        inner_cone: c.br_angle = degrees(10.0),
    },
};

pub const RGB = packed struct(u32) {
    b: u8 = 0,
    r: u8 = 0,
    g: u8 = 0,
    _: u8 = undefined,

    pub const white: RGB = .{ .r = 255, .g = 255, .b = 255 };
    pub const red: RGB = .{ .r = 255 };
    pub const green: RGB = .{ .g = 255 };
    pub const blue: RGB = .{ .b = 255 };
};

pub const Scalar = c.br_scalar;
pub const Vertex = c.br_vertex;
pub const VertexGroup = c.br_vertex_group;
pub const Face = c.br_face;
pub const FaceGroup = c.br_face_group;

pub const Matrix23 = extern struct {
    m: [3][2]Scalar = std.mem.zeroes([3][2]Scalar),

    pub const identity: Matrix23 = .{ .m = .{
        vec2(1, 0),
        vec2(0, 1),
        vec2(0, 0),
    } };
};

pub const Matrix34 = extern struct {
    m: [4][3]Scalar = std.mem.zeroes([4][3]Scalar),

    pub const identity: Matrix34 = .{ .m = .{
        vec3(1, 0, 0),
        vec3(0, 1, 0),
        vec3(0, 0, 1),
        vec3(0, 0, 0),
    } };

    pub const translate = BrMatrix34Translate;
    pub const rotateY = BrMatrix34RotateY;
    pub const postRotateZ = BrMatrix34PostRotateZ;

    extern fn BrMatrix34Translate(mat: *Matrix34, x: Scalar, y: Scalar, z: Scalar) void;
    extern fn BrMatrix34RotateY(mat: *Matrix34, ry: c.br_angle) void;
    extern fn BrMatrix34PostRotateZ(mat: *Matrix34, rz: c.br_angle) void;
};

pub const Light = c.br_light;
pub const Camera = c.br_camera;
pub const TransformType = enum(u16) {
    matrix = c.BR_TRANSFORM_MATRIX34,
    quaternion = c.BR_TRANSFORM_QUAT,
    euler = c.BR_TRANSFORM_EULER,
    look_up = c.BR_TRANSFORM_LOOK_UP,
    translate = c.BR_TRANSFORM_TRANSLATION,
};

pub const Transform = union(TransformType) {
    matrix: Matrix34,
    quaternion: extern struct {
        q: Quaternion = @import("std").mem.zeroes(Quaternion),
        _pad: [5]Scalar = @import("std").mem.zeroes([5]Scalar),
        t: Vector3 = @import("std").mem.zeroes(Vector3),
    },
    euler: extern struct {
        e: Euler = @import("std").mem.zeroes(Euler),
        _pad: [7]Scalar = @import("std").mem.zeroes([7]Scalar),
        t: Vector3 = @import("std").mem.zeroes(Vector3),
    },
    look_up: extern struct {
        look: Vector3 = @import("std").mem.zeroes(Vector3),
        up: Vector3 = @import("std").mem.zeroes(Vector3),
        _pad: [3]Scalar = @import("std").mem.zeroes([3]Scalar),
        t: Vector3 = @import("std").mem.zeroes(Vector3),
    },
    translate: extern struct {
        _pad: [9]Scalar = @import("std").mem.zeroes([9]Scalar),
        t: Vector3 = @import("std").mem.zeroes(Vector3),
    },

    pub inline fn getTranslation(self: Transform) Vector3 {
        switch (self) {
            .matrix => |m| return m[2],
            inline else => |t| return t.t,
        }
    }

    pub inline fn setTranslation(self: *Transform, new_value: Vector3) void {
        switch (self) {
            .matrix => |*m| m.*[2] = new_value,
            inline else => |*t| t.t = new_value,
        }
    }

    pub fn init(actor: *Actor) Transform {
        const tt: TransformType = @enumFromInt(actor.node.t.type);
        return switch (tt) {
            inline else => |tag| @unionInit(Transform, @tagName(tag), @bitCast(actor.node.t.t)),
        };
    }
};

pub const begin = c.BrBegin;
pub const end = c.BrEnd;
pub const beginZb = c.BrZbBegin;
pub const endZb = c.BrZbEnd;

pub inline fn scalar(n: f32) Scalar {
    return @intFromFloat(n * @as(f32, @floatFromInt(c.BR_ONE_LS)));
}

pub fn Fraction(comptime signedness: enum { signed, unsigned }) type {
    return switch (signedness) {
        .signed => c.br_fraction,
        .unsigned => c.br_ufraction,
    };
}

pub inline fn ufrac(n: f32) c.br_ufraction {
    return @intFromFloat(if (@as(f32, @floatFromInt(c.BR_ONE_LUF)) * n >= @as(f32, @floatFromInt(c.BR_ONE_LUF))) @as(f32, @floatFromInt(c.BR_ONE_LUF - 1)) else @as(f32, @floatFromInt(c.BR_ONE_LUF)) * n);
}
pub const Euler = c.br_euler;
pub const Quaternion = c.br_quat;
pub const Vector2 = [2]Scalar;
pub const Vector3 = [3]Scalar;
pub const Bounds3 = c.br_bounds3;

pub inline fn vec2(x: f32, y: f32) Vector2 {
    return .{ scalar(x), scalar(y) };
}

pub inline fn vec3(x: f32, y: f32, z: f32) Vector3 {
    return .{ scalar(x), scalar(y), scalar(z) };
}

pub inline fn div(x: f32, y: f32) Scalar {
    return scalar(x / y);
}

// TODO: is this correct?
pub inline fn angle(n: f32) c.br_angle {
    const absolute: u32 = @intFromFloat(@abs(n));
    const magnitude: u16 = @intCast(absolute % std.math.maxInt(u16));

    return if (n < 0) 0 -% magnitude else magnitude;
}

pub inline fn degrees(n: f32) c.br_angle {
    return angle(n * 182.0);
}

pub inline fn radians(n: f32) c.br_angle {
    return angle(n * 10430.0);
}

const std = @import("std");
const assert = std.debug.assert;
