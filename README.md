# Repro steps

## Expected behavior

1. Run `buck2 build --target-platforms //:linux //:test` on macOS or `buck2 build --target-platforms //:macos //:test` on Linux
2. buck2 builds successfully because it knows to download python for the execution platform as opposed to the target platform.

## Actual behavior

1. Run `buck2 build --target-platforms //:linux //:test` on macOS or `buck2 build --target-platforms //:macos //:test` on Linux
2. buck2 fails with the following error:

```
$ buck2 build --target-platforms //:linux //:test
Action failed: root//:test (json)
Local command returned non-zero exit code 126
Reproduce locally: `env -- 'BUCK_SCRATCH_PATH=buck-out/v2/tmp/root/21b199e98f91f821/__test__/json' buck-out/v2/gen/toolc ...<omitted>... n_file.py --arg hello ./world.txt --filename buck-out/v2/gen/root/21b199e98f91f821/__test__/out.json (run `buck2 log what-failed` to get the full command)`
stdout:
stderr:
/Users/dan/devel/buck2-python-toolchain-problem/buck-out/v2/gen/toolchains/21b199e98f91f821-21b199e98f91f821/__python__/__python/python/install/bin/python3: /Users/dan/devel/buck2-python-toolchain-problem/buck-out/v2/gen/toolchains/21b199e98f91f821-21b199e98f91f821/__python__/__python/python/install/bin/python3: cannot execute binary file
Build ID: 84703265-25da-41e7-a709-b62506709b2c
Network: Up: 0B  Down: 34MiB
Jobs completed: 63. Time elapsed: 4.8s.
Cache hits: 0%. Commands: 2 (cached: 0, remote: 0, local: 2)
BUILD FAILED
Failed to build 'root//:test (root//:linux#21b199e98f91f821)'
```

Sure enought that's the Linux version of python, but I asked for the macOS version:

```
$ file buck-out/v2/gen/toolchains/21b199e98f91f821-21b199e98f91f821/__python__/__python/python/install/bin/python
buck-out/v2/gen/toolchains/21b199e98f91f821-21b199e98f91f821/__python__/__python/python/install/bin/python: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, with debug_info, not stripped
```
