[![Build Syphon macOS Universal](https://github.com/hiroMTB/syphon-builder/actions/workflows/ci-macOS.yaml/badge.svg)](https://github.com/hiroMTB/syphon-builder/actions/workflows/ci-macOS.yaml)

# Syphon Framework CI pipeline

- Builds [Syphon Framework](https://github.com/Syphon/Syphon-Framework) as a universal (arm64 + x64) framework for macOS
- Prebuilt frameworks are available on the [Releases page](https://github.com/hiroMTB/syphon-builder/releases)

## Download

Download `Syphon_vX.Y.Z.zip` from the latest release. It contains:

```
Syphon_vX.Y.Z/
└── Syphon.framework
```

## Build locally

```bash
./mac-local-build.sh
```

The built framework will be at `build/Release/Syphon.framework` (universal arm64 + x64).

## Patches

Custom patches are stored in `patches/` and applied automatically during the build. Currently there are no patches.
