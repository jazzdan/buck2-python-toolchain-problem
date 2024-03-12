JSONToolchainInfo = provider(
    fields={
        "json_file": typing.Any,
    }
)


def json_toolchain_impl(ctx) -> list[[DefaultInfo, JSONToolchainInfo]]:
    """
    A JSON toolchain.
    """
    return [
        DefaultInfo(),
        JSONToolchainInfo(
            json_file=ctx.attrs._json_file,
        ),
    ]


json_toolchain = rule(
    impl=json_toolchain_impl,
    attrs={
        "_json_file": attrs.dep(
            default="prelude-replay//json:json_file.py",
        ),
    },
    is_toolchain_rule=True,
)
