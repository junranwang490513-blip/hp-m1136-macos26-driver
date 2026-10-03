# HP LaserJet M1136 on modern macOS

[简体中文](README.zh-CN.md) | English

An unofficial, open-source printing workaround for the **HP LaserJet Professional M1136 MFP** on modern macOS. It replaces HP's retired host-based print path with Ghostscript and `foo2xqx` from OpenPrinting's `foo2zjs` project.

## What was actually tested

- Printer: HP LaserJet Professional M1136 MFP, connected directly by USB
- Mac: Apple Silicon (`arm64`), macOS 26.1
- Result: two macOS test pages printed successfully at A4 / 1200×600 dpi
- Scope: **printing only**; scanning is not installed or claimed
- Installer: version 1.1.0, unsigned, community-built

Only the M1136 result above is a local test. Similar models below are research leads, not promises that this M1136-specific installer will configure them.

## Download and install

1. Download [`HP-LaserJet-M1136-macOS26-arm64.pkg`](dist/HP-LaserJet-M1136-macOS26-arm64.pkg).
2. Verify its SHA-256 against [`checksums/SHA256SUMS`](checksums/SHA256SUMS).
3. Connect the M1136 by USB, power it on, and run the package as an administrator.
4. If the printer was disconnected during installation, reconnect it and run:

   ```sh
   sudo /Library/Printers/hp-m1136/configure-printer.sh
   ```

The installer intentionally succeeds when the printer is absent: it installs the driver files and defers only queue creation. This fixes the earlier misleading installation failure caused by a disconnected or powered-off printer.

The package is not signed or notarized. Inspect the scripts and checksum before use. It installs under `/Library/Printers/hp-m1136`, creates the `HP_LaserJet_M1136` CUPS queue, and does not upload print data or contact a network service.

## Compatibility map

| Status | Models | Meaning |
|---|---|---|
| ✅ Locally verified | **HP LaserJet Professional M1136 MFP** | This repository's installer and queue configuration were tested |
| 🟡 Explicit `foo2xqx` candidates | HP LaserJet M1005 MFP, M1120 MFP, P2014/P2014n, M1132s MFP, M1212nf MFP | Explicitly mapped upstream to the same converter, but untested here; each needs its own PPD, USB matching and installer |
| 🟡 Same product series; unverified | HP LaserJet Pro M1132, M1139, M1213nf/M1214nfh/M1216nfh/M1217nfw/M1218nfs/M1219nf | HP lists these in the related M1130/M1210 families; upstream does not provide a dedicated mapping for every regional variant |
| 🧪 Firmware-dependent `foo2xqx` candidates | HP LaserJet P1005/P1006/P1007/P1008, P1505/P1505n | Require proprietary firmware after power-on; P1005–P1009 also use a special 600×400 mode. Firmware is not included |
| ❌ Different driver path | HP P1102/P1102w/P1566/P1606dn, older 10xx/1022, P2035 series and HP color models | Upstream uses another ZjStream variant, OAKT, `foo2hp`, or another path. They need a separate package |

The upstream `foo2zjs` tree also contains PPDs for selected Dell, Epson, Fuji Xerox, Konica Minolta, Kyocera, Lexmark, Minolta, Oki, Samsung and Xerox models using other protocols. **They are not compatible with this M1136 package and need separate packages.** See [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md) before attempting any port.

## Why this works

The M1136 is a USB, host-based printer rather than a native PostScript/PCL/AirPrint device. The working pipeline is:

```text
application → CUPS PDF → bundled Ghostscript → PBM raster → foo2xqx → XQX stream → USB printer
```

The current `foo2xqx` build uses `MX=0`, the upstream fix reported to stop intermittent corrupted output on the M1136. The runtime is placed under `/Library/Printers`, where modern macOS permits the CUPS filter to execute.

## Troubleshooting

Confirm that macOS sees the printer:

```sh
system_profiler SPUSBDataType | grep -A 12 -i 'M1136'
```

Check the project log and Apple's installer log:

```sh
tail -n 100 /var/log/hp-m1136-driver-install.log
tail -n 200 /var/log/install.log
```

Check queue state:

```sh
lpstat -t
```

When reporting another model, include the model name, macOS version, Mac architecture, USB-only or network connection, the printer's IEEE-1284 `CMD` value if available, and the result. **Remove serial numbers, usernames, tokens and private paths from logs before posting.**

## Source, privacy and licenses

- Driver source: [OpenPrinting/foo2zjs](https://github.com/OpenPrinting/foo2zjs), commit `80499ed5bf6caa2963ad337e37cfda78a80aab1e`
- Runtime packaging reference: [ardabeh/hp-legacy-mac](https://github.com/ardabeh/hp-legacy-mac), commit `fff005c`
- Bundled Ghostscript: 10.07.1
- Upstream runtime archive used during this build: SHA-256 `60c133b5a53fcce4a4364e1da53d8815cf6b14549e4eba2e88f567fdb6ee950b`


Project glue and `foo2zjs`-derived files are distributed under GPL-2.0; see [`LICENSE`](LICENSE) and [`LICENSES/GPL-2.0.txt`](LICENSES/GPL-2.0.txt). Ghostscript is distributed under AGPL-3.0-or-later; see [`LICENSES/AGPL-3.0.txt`](LICENSES/AGPL-3.0.txt) and [`THIRD_PARTY.md`](THIRD_PARTY.md). This project is unaffiliated with HP, Apple, OpenPrinting or Artifex and is provided without warranty.
