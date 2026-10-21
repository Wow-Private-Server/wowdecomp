# Cloud build (Linux)

Builds the x64 client on Linux with clang-cl and lld-link, runs it under Wine and records the screen. Meant for
cloud/CI sessions; Windows with Visual Studio stays the main build.

```sh
Tools/CloudBuild/setup.sh                 # once per machine: Wine, Xvfb, ffmpeg, MSVC + Windows SDK into /opt/msvc
Tools/CloudBuild/build.sh                 # bin/Win/WowClient64.exe, Wow64.exe, XvidDecoder.dll
Tools/CloudBuild/record.sh 30 run.mp4     # run WowClient64.exe under Wine on a virtual display, record 30 s
```

`build.sh` passes extra arguments to CMake (`-DWOWDECOMP_DISABLE_SIGNATURE_CHECKS=ON`, ...). `record.sh` passes
arguments after the output file to the client and reads `WOW_EXE`, `RECORD_SIZE` and `RECORD_DISPLAY`.

## How it differs from the Windows build

- The toolset comes from NuGet, since the Visual Studio download hosts are not reachable from every network:
  the Windows SDK 10.0.26100 (headers, import libs, UCRT) and the VS2017 MSVC 14.11 layout (STL, vcruntime,
  CRT libs). `mkoverlay.py` gives clang and lld a case-insensitive view of them.
- `compat/filesystem` maps `std::filesystem` onto the Filesystem TS that the 14.11 STL ships (`BugReport.cpp`).
- Rendering goes through Wine's Direct3D 9 on Mesa llvmpipe (software OpenGL), so frame rates are low.
- Running still needs the `Data` folder of a 3.3.5a client in `bin/Win/Data/`, same as on Windows.
