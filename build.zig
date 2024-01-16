const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const no_fixed_point = b.option(
        bool,
        "no-fixed",
        "Use floating-point instead of fixed-point in BRender math routines.",
    ) orelse false;

    const little_endian = target.result.cpu.arch.endian() == .little;

    const lib = b.addStaticLibrary(.{
        .name = "brender",
        .target = target,
        .optimize = optimize,
    });

    lib.installHeadersDirectory("INC", "");

    lib.addCSourceFiles(.{ .files = brfwm_sources });
    lib.addCSourceFiles(.{ .files = brzbm_sources });
    lib.addCSourceFiles(.{ .files = brfmm_sources });
    lib.addCSourceFiles(.{ .files = brstm_sources });

    if (target.result.os.tag == .wasi) lib.defineCMacro("__H2INC__", null);
    lib.defineCMacro(if (no_fixed_point) "BASED_FLOAT" else "BASED_FIXED", "1");
    lib.defineCMacro("BR_ENDIAN_BIG", if (little_endian) "0" else "1");
    lib.defineCMacro("BR_ENDIAN_LITTLE", if (little_endian) "1" else "0");

    lib.addIncludePath(.{ .path = "INC" });
    lib.addIncludePath(.{ .path = "FW" });
    lib.linkLibC();
    lib.root_module.sanitize_c = false;

    b.installArtifact(lib);
}

const brfwm_sources = &.{
    "FW/actsupt.c",
    "FW/angles.c",
    "FW/brlists.c",
    "FW/brqsort.c",
    "FW/bswap.c",
    "FW/custsupt.c",
    "FW/datafile.c",
    "FW/def_mdl.c",
    "FW/def_mat.c",
    "FW/diag.c",
    "FW/envmap.c",
    "FW/error.c",
    "FW/ffhooks.c",
    "FW/file.c",
    "FW/fileops.c",
    "FW/fixed.c",
    "FW/fontptrs.c",
    "FW/fwsetup.c",
    "FW/light8.c",
    "FW/light8o.c",
    "FW/light24.c",
    "FW/light24o.c",
    "FW/logprint.c",
    "FW/matrix23.c",
    "FW/matrix34.c",
    "FW/matrix4.c",
    "FW/mem.c",
    "FW/onscreen.c",
    "FW/pick.c",
    "FW/pixelmap.c",
    "FW/pmdsptch.c",
    "FW/pmgenops.c",
    "FW/pmmemops.c",
    "FW/pool.c",
    "FW/prelight.c",
    "FW/prepmatl.c",
    "FW/prepmesh.c",
    "FW/prepmap.c",
    "FW/preptab.c",
    "FW/quat.c",
    "FW/quantize.c",
    "FW/register.c",
    "FW/regsupt.c",
    "FW/resource.c",
    "FW/scalar.c",
    "FW/scale.c",
    "FW/scratch.c",
    "FW/scrstr.c",
    "FW/surface.c",
    "FW/transfrm.c",
    "FW/vector.c",
    "FW/fixed_agnostic.c",
    "FW/blockops.c",
    "FW/font_f_3x5.c",
    "FW/font_p_4x6.c",
    "FW/font_p_7x9.c",
    "FW/memloops.c",
};

const brzbm_sources = &.{
    "ZB/awtmz.c",
    "ZB/bbox.c",
    "ZB/decalz.c",
    "ZB/dither.c",
    "ZB/frcp.c",
    "ZB/l_piz.c",
    "ZB/p_piz.c",
    "ZB/perspz.c",
    "ZB/zbclip.c",
    "ZB/zbmatl.c",
    "ZB/zbmesh.c",
    "ZB/zbmeshe.c",
    "ZB/zbmeshp.c",
    "ZB/zbrendr.c",
    "ZB/zbsetup.c",
    "ZB/mesh_agnostic.c",
    "ZB/safediv.c",
    "ZB/t_piza.c",
    // "ZB/ti8_pizp.c",
    "ZB/ti8_piz.c",
    "ZB/tt15_piz.c",
    "ZB/tt24_piz.c",
};

const brfmm_sources = &.{
    "FMT/strcasecmp.c",
    "FMT/loadnff.c",
    "FMT/loadasc.c",
    "FMT/loadscr.c",
    "FMT/loadgif.c",
    "FMT/loadiff.c",
    "FMT/loadbmp.c",
    "FMT/loadtga.c",
    "FMT/savescr.c",
};

const brstm_sources = &.{
    "STD/stdfile.c",
    "STD/stdmem.c",
    "STD/stddiag.c",
};
