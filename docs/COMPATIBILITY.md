# Compatibility research / 兼容性调研

This document distinguishes three different claims: a driver project contains a PPD, another maintainer tested a model, and this repository tested a physical printer. Those claims are not interchangeable.

本文严格区分三件事：上游项目收录了 PPD、其他维护者测试过某型号、本项目用实体打印机测试通过。三者不能画等号。

## Evidence used / 证据来源

- [OpenPrinting/foo2zjs](https://github.com/OpenPrinting/foo2zjs): driver source and model PPD database.
- [OpenPrinting issue #6](https://github.com/OpenPrinting/foo2zjs/issues/6): M1136 field report using the M1132 configuration, including intermittent corrupted output.
- [OpenPrinting PR #8](https://github.com/OpenPrinting/foo2zjs/pull/8): `foo2xqx` `MX=0` change reported to fix M1136 output and merged upstream.
- [OpenPrinting `foo2xqx` mapping](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/foomatic-db/driver/foo2xqx.xml): explicit models assigned to this converter.
- [OpenPrinting firmware helper](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/hplj1000): firmware-dependent model aliases and upload flow.
- [HP M1130/M1210 family list](https://support.hp.com/in-en/document/c02003606): related regional models, which still require individual verification.
- [Apple HP Printer Drivers 5.1.1](https://support.apple.com/en-us/106385): Apple's legacy package is not compatible with macOS 12 and later.
- [ardabeh/hp-legacy-mac](https://github.com/ardabeh/hp-legacy-mac): modern macOS packaging, its verified CP1025 result, and its firmware/no-firmware classification.
- [PavlentijKr/hp-m1132-macos](https://github.com/PavlentijKr/hp-m1132-macos): an independent M1132 package and same-engine candidate list.

## Porting checklist / 移植检查清单

Do not rename the M1136 PPD and assume success. For each new model:

不要只修改 M1136 的型号名就认为适配成功。每个新型号都应完成：

1. Confirm USB vendor/product identification and IEEE-1284 `CMD`.
2. Select the upstream PPD and matching converter (`foo2xqx`, `foo2zjs`, `foo2hbpl2`, etc.).
3. Determine whether firmware must be uploaded after power-on and whether redistribution is permitted.
4. Generate a model-specific queue configuration without matching a user's serial number.
5. Test plain text, PDF, images, multi-page jobs, A4/Letter, cancellation and a power cycle.
6. Record macOS version, CPU architecture and connection type; redact private identifiers.

P1102/P1102w/P1566/P1606dn and many older or color HP models also use a different upstream path, so they are not compatible with this package. Models from non-HP vendors appear in the upstream tree because `foo2zjs` is a family of drivers, not because this M1136 filter is universal. A new converter path and PPD may be required.

P1102/P1102w/P1566/P1606dn 以及许多更老或彩色 HP 型号也采用不同的上游链路，因此不兼容当前安装包。其他厂商型号出现在上游目录，是因为 `foo2zjs` 是一组驱动，而不是因为 M1136 的过滤器可以通用。它们往往需要不同的转换器和 PPD。
