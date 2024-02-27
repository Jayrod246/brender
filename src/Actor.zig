node: c.br_actor,

const Actor = @This();

pub const ActorType = enum(u8) {
    none = c.BR_ACTOR_NONE,
    model = c.BR_ACTOR_MODEL,
    light = c.BR_ACTOR_LIGHT,
    camera = c.BR_ACTOR_CAMERA,
    reserved = c._BR_ACTOR_RESERVED,
    bounds = c.BR_ACTOR_BOUNDS,
    bounds_correct = c.BR_ACTOR_BOUNDS_CORRECT,
    clip_plane = c.BR_ACTOR_CLIP_PLANE,
};

pub const ActorTypeData = union(ActorType) {
    none: void,
    model: struct { **br.Model, **br.Material },
    light: *br.Light,
    camera: *br.Camera,
    reserved: void,
    bounds: void,
    bounds_correct: void,
    clip_plane: void,
};

pub const ActorAllocOptions = union(ActorType) {
    none: void,
    model: struct { model: *br.Model, material: *br.Material },
    light: br.LightType,
    camera: br.Camera,
    reserved: void,
    bounds: void,
    bounds_correct: void,
    clip_plane: void,
};

pub const add = BrActorAdd;
pub inline fn addAlloc(self: *Actor, opts: ActorAllocOptions) *Actor {
    return self.add(alloc(opts) orelse @panic("oom"));
}

pub inline fn alloc(opts: ActorAllocOptions) ?*Actor {
    const actor = BrActorAllocate(opts, null) orelse return null;
    actor.init(opts);
    return actor;
}

pub fn init(self: *Actor, opts: ActorAllocOptions) void {
    assert(self.node.type == @intFromEnum(opts));
    switch (opts) {
        .none => {
            return;
        },
        .model => |input| {
            const set_model, const set_material = self.getTypeData().model;
            set_model.* = input.model;
            set_material.* = @alignCast(@ptrCast(input.material));
        },
        .light => |input| {
            self.getTypeData().light.* = switch (input) {
                .directional => |dl| .{
                    .type = c.BR_LIGHT_DIRECT,
                    .colour = @bitCast(dl.color),
                    .attenuation_c = dl.constant_attenuation,
                },
                .point => |pl| .{
                    .type = c.BR_LIGHT_POINT,
                    .colour = @bitCast(pl.color),
                    .attenuation_c = pl.constant_attenuation,
                    .attenuation_l = pl.linear_attenuation,
                    .attenuation_q = pl.quadratic_attenuation,
                },
                .spot => |sl| .{
                    .type = c.BR_LIGHT_SPOT,
                    .colour = @bitCast(sl.color),
                    .attenuation_c = sl.constant_attenuation,
                    .attenuation_l = sl.linear_attenuation,
                    .attenuation_q = sl.quadratic_attenuation,
                    .cone_outer = sl.outer_cone,
                    .cone_inner = sl.inner_cone,
                },
            };
        },
        .reserved, .bounds, .bounds_correct, .clip_plane => @panic("not implemented"),
        .camera => |camera| {
            self.getTypeData().camera.* = camera;
        },
    }
}

pub fn enable(self: *Actor, on: bool) void {
    const tag: ActorType = @enumFromInt(self.node.type);
    switch (tag) {
        .light => if (on) self.BrLightEnable() else self.BrLightDisable(),
        .clip_plane => if (on) self.BrClipPlaneEnable() else self.BrClipPlaneDisable(),
        else => unreachable,
    }
}

extern fn BrClipPlaneEnable(self: *Actor) void;
extern fn BrClipPlaneDisable(self: *Actor) void;

extern fn BrLightEnable(self: *Actor) void;
extern fn BrLightDisable(self: *Actor) void;

extern fn BrActorAdd(parent: *Actor, child: *Actor) *Actor;
extern fn BrActorAllocate(actor_type: ActorType, type_data: ?*anyopaque) ?*Actor;

pub fn getTypeData(self: *Actor) ActorTypeData {
    const tag: ActorType = @enumFromInt(self.node.type);
    switch (tag) {
        .model => {
            return .{
                .model = .{
                    @alignCast(@ptrCast(&self.node.model)), @alignCast(@ptrCast(&self.node.material)),
                },
            };
        },
        inline else => |x| {
            const is_void = comptime blk: {
                break :blk std.meta.TagPayload(ActorTypeData, x) == void;
            };
            if (is_void)
                return @unionInit(ActorTypeData, @tagName(x), {});
            return @unionInit(ActorTypeData, @tagName(x), @alignCast(@ptrCast(self.node.type_data.?)));
        },
    }
}

pub inline fn getTransform(self: *Actor) br.Transform {
    return br.Transform.init(self);
}
pub fn setTransform(self: *Actor, new_transform: br.Transform) void {
    switch (new_transform) {
        inline else => |t, ty| {
            self.node.t.type = @intFromEnum(ty);
            self.node.t.t = @bitCast(t);
        },
    }
}

const br = @import("brender.zig");
const c = br.c;
const std = @import("std");
const assert = std.debug.assert;
