load("@prelude//python:toolchain.bzl", "PythonToolchainInfo")
load("//json:toolchain.bzl", "JSONToolchainInfo")


def json_file_impl(ctx: AnalysisContext) -> list[Provider]:
    json_output_name = (
        ctx.attrs.out if ctx.attrs.out else "{}.json".format(ctx.label.name)
    )
    json_file = ctx.actions.declare_output(json_output_name)

    json_toolchain = ctx.attrs._json_toolchain[JSONToolchainInfo]

    cmd = cmd_args(
        ctx.attrs._python_toolchain[PythonToolchainInfo].interpreter,
        json_toolchain.json_file[DefaultInfo].default_outputs,
    )

    for key, value in ctx.attrs.args.items():
        cmd.add("--arg")
        cmd.add(key)
        cmd.add(value)

    cmd.add("--filename")
    cmd.add(json_file.as_output())

    ctx.actions.run(cmd, category="json")

    return [DefaultInfo(default_output=json_file)]


json_file = rule(
    impl=json_file_impl,
    attrs={
        "args": attrs.dict(key=attrs.string(), value=attrs.source()),
        "out": attrs.option(attrs.string(), default=None),
        "_python_toolchain": attrs.toolchain_dep(
            default="toolchains//:python",
            providers=[PythonToolchainInfo],
        ),
        "_json_toolchain": attrs.toolchain_dep(
            default="toolchains//:json",
            providers=[JSONToolchainInfo],
        ),
    },
)
