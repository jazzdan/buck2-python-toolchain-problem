load(
    "@prelude//python:toolchain.bzl",
    "PythonPlatformInfo",
    "PythonToolchainInfo",
)
load(
    "@prelude//:artifacts.bzl",
    "ArtifactGroupInfo",
)


def _host_os() -> str:
    os = host_info().os
    if os.is_linux:
        return "linux"
    elif os.is_macos:
        return "darwin"
    elif os.is_windows:
        return "windows"
    else:
        fail("Unsupported host os.")


def _interpreter_fmt(interpreter: str) -> str:
    if _host_os() == "windows":
        return "{}" + "/python/install/{}".format(interpreter)
    else:
        return "{}" + "/python/install/bin/{}".format(interpreter)


def _standalone_python_impl(ctx: AnalysisContext) -> list[Provider]:
    # generate a runnable python3 binary
    python = ctx.actions.declare_output("__python", dir=True)
    ctx.actions.copy_dir(python, ctx.attrs.archive)
    interpreter = ctx.attrs.interpreter
    interpreter_fmt = _interpreter_fmt(interpreter)
    interpreter_args = cmd_args(python, format=interpreter_fmt).hidden(python)

    # provide relavant headers for pybind, if we ever need that
    includes = ctx.actions.declare_output("include", dir=True)
    ctx.actions.copy_file(includes, python.project("python/install/include/python3.11"))

    return [
        DefaultInfo(
            sub_targets={
                "interpreter": [RunInfo(interpreter)],
                "includes": [DefaultInfo(includes)],
            }
        ),
        PythonToolchainInfo(
            fail_with_message=ctx.attrs.fail_with_message[RunInfo],
            make_source_db=ctx.attrs.make_source_db[RunInfo],
            make_source_db_no_deps=ctx.attrs.make_source_db_no_deps[RunInfo],
            host_interpreter=RunInfo(args=[ctx.attrs.interpreter]),
            interpreter=RunInfo(args=interpreter_args),
            make_py_package_modules=ctx.attrs.make_py_package_modules[RunInfo],
            make_py_package_inplace=ctx.attrs.make_py_package_inplace[RunInfo],
            compile=RunInfo(args=["echo", "COMPILEINFO"]),
            package_style="inplace",
            native_link_strategy="separate",
            runtime_library=ctx.attrs.runtime_library,
        ),
    ]


standalone_python = rule(
    impl=_standalone_python_impl,
    attrs={
        "archive": attrs.source(),
        # everything below is copied from prelude/toolchains/python.bzl system_python_toolchain
        "fail_with_message": attrs.default_only(
            attrs.dep(
                providers=[RunInfo], default="prelude//python/tools:fail_with_message"
            )
        ),
        "interpreter": attrs.string(default="python3"),
        "make_py_package_inplace": attrs.default_only(
            attrs.dep(
                providers=[RunInfo],
                default="prelude//python/tools:make_py_package_inplace",
            )
        ),
        "make_py_package_modules": attrs.default_only(
            attrs.dep(
                providers=[RunInfo],
                default="prelude//python/tools:make_py_package_modules",
            )
        ),
        "make_source_db": attrs.default_only(
            attrs.dep(
                providers=[RunInfo], default="prelude//python/tools:make_source_db"
            )
        ),
        "make_source_db_no_deps": attrs.default_only(
            attrs.dep(
                providers=[RunInfo],
                default="prelude//python/tools:make_source_db_no_deps",
            )
        ),
        "runtime_library": attrs.default_only(
            attrs.dep(
                providers=[ArtifactGroupInfo],
                default="prelude//python/runtime:bootstrap_files",
            )
        ),
    },
    is_toolchain_rule=True,
)
