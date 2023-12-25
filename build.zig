const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "libuiohook",
        .target = target,
        .optimize = optimize,
    });
    const t = lib.target_info.target;

    lib.addIncludePath(.{ .path = "include" });
    lib.addIncludePath(.{ .path = "src" });
    lib.addCSourceFiles(.{ .files = &generic_src_files });
    lib.linkLibC();

    switch (t.os.tag) {
        .windows => {
            lib.addCSourceFiles(.{ .files = &windows_src_files });
        },
        .linux => {
            lib.addCSourceFiles(.{ .files = &linux_src_files });
            lib.linkSystemLibrary("x11");
            lib.linkSystemLibrary("xtst");
            lib.linkSystemLibrary("xt");
            lib.linkSystemLibrary("xinerama");
            lib.linkSystemLibrary("x11-xcb");
            lib.linkSystemLibrary("xkbcommon");
            lib.linkSystemLibrary("xkbcommon-x11");
            lib.linkSystemLibrary("xkbfile");
        },
        .macos => {
            lib.addCSourceFiles(.{ .files = &darwin_src_files });
        },
        else => {},
    }

    lib.installHeadersDirectory("include", "libuiohook");
    b.installArtifact(lib);
}

const generic_src_files = [_][]const u8{
    "src/logger.c",
};

const windows_src_files = [_][]const u8{
    "src/windows/input_helper.c",
    "src/windows/input_hook.c",
    "src/windows/post_event.c",
    "src/windows/system_properties.c",
};

const linux_src_files = [_][]const u8{
    "src/x11/input_helper.c",
    "src/x11/input_hook.c",
    "src/x11/post_event.c",
    "src/x11/system_properties.c",
};

const darwin_src_files = [_][]const u8{
    "src/darwin/input_helper.c",
    "src/darwin/input_hook.c",
    "src/darwin/post_event.c",
    "src/darwin/system_properties.c",
};
