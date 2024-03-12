# A list of available rules and their signatures can be found here: https://buck2.build/docs/api/rules/

load(
    "@prelude-replay//:macros.bzl",
    "json_file",
)


genrule(
    name = "hello_world",
    out = "out.txt",
    cmd = "echo BUILT BY BUCK2> $OUT",
)

json_file(
    name="test",
    out="out.json",
    args={
        "hello": "world.txt",
    },
)
