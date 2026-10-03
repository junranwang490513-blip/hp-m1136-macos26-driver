# Third-party software notices

The binary installer contains third-party open-source software. No HP proprietary firmware is included.

| Component | Version / revision | License | Source |
|---|---|---|---|
| OpenPrinting `foo2zjs`, including `foo2xqx` | `80499ed5bf6caa2963ad337e37cfda78a80aab1e` | GPL-2.0 | https://github.com/OpenPrinting/foo2zjs |
| Ghostscript | 10.07.1 | AGPL-3.0-or-later | https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/tag/gs10071 |
| Runtime packaging reference | `ardabeh/hp-legacy-mac` at `fff005c` | GPL-2.0 | https://github.com/ardabeh/hp-legacy-mac |

The installer also carries dynamic libraries needed by the self-contained Ghostscript executable. Their copyright notices and source locations remain those of their respective projects. Rebuild instructions are in [`scripts/build-package.sh`](scripts/build-package.sh); the exact upstream runtime archive used for this release has SHA-256 `60c133b5a53fcce4a4364e1da53d8815cf6b14549e4eba2e88f567fdb6ee950b`.

License texts are provided in [`LICENSES`](LICENSES). This notice is informational and is not legal advice.
