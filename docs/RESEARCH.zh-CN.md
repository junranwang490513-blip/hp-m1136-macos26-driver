# HP M1136 macOS 26 驱动：兼容性证据整理

研究日期：2026-10-03
研究对象：当前 `HP-LaserJet-M1136-macOS26-arm64.pkg` 及其所采用的 OpenPrinting `foo2xqx`/`foo2zjs` 代码。
证据范围：仅使用 OpenPrinting/foo2zjs 上游仓库、上游 issue/已合并 PR、HP 官方支持页/手册和 Apple 官方支持页。

## 先说结论

1. **当前发布包唯一可以写成“本项目已在真机上验证”的型号是 HP LaserJet Professional M1136 MFP。** 本地测试完成了 USB 识别、队列创建和实际出纸；上游也有人在 M1136 真机上验证过 `foo2xqx` 及 `MX=0` 修复。
2. 当前包的安装后脚本把 USB 名称、队列名和 PPD 固定为 M1136。即使包内带有其他上游二进制/PPD，**双击安装并不等于自动支持其他型号**。
3. 最值得作为下一批独立适配目标的是上游明确列为 `foo2xqx` 目标、且不要求运行时固件的型号：M1005 MFP、M1120 MFP、P2014/P2014n、M1132s MFP、M1212nf MFP。它们有上游 PPD/设备条目，但本项目尚未真机验证。
4. M1130/M1210 同系列的其他地区型号（M1132、M1139、M1213nf、M1214nfh、M1216nfh、M1217nfw、M1218nfs、M1219nf）可列为“同系列、可能兼容”，不能写成已支持。需要取得 USB IEEE-1284 Device ID、生成型号专用 PPD，并在真机打印测试。
5. P1005/P1006/P1007/P1008/P1505（以及 USB 使用场景下的 P1505n）虽然是上游 `foo2xqx` 目标，但依赖可下载固件，并且 P1005–P1009 有特殊的 600×400 模式。当前包没有随附/加载这些固件，应标为实验性，不能承诺即装即用。
6. P1102/P1102w/P1566/P1606dn 等使用 `foo2zjs-z2`，其他品牌使用 QPDL、HIPERC、HBPL2、LAVAFLOW 等不同协议。它们不是 M1136/foo2xqx 包的兼容型号，只能作为未来“另做型号包”的候选。

## 严格分级

### A. 本项目本地真机验证

| 型号 | 结论 | 范围与限制 | 证据 |
|---|---|---|---|
| HP LaserJet Professional M1136 MFP | **已验证** | Apple Silicon + macOS 26；USB 打印；实际出纸。当前项目不宣称扫描功能。 | 本项目本地测试；[HP 官方规格：Host-based、USB 2.0、600×600 dpi](https://support.hp.com/us-en/product/product-specs/hp-laserjet-pro-m1136-multifunction-printer-series/5094778/)；[上游 M1136 issue #6](https://github.com/OpenPrinting/foo2zjs/issues/6)；[已合并的 M1136 真机修复 PR #8](https://github.com/OpenPrinting/foo2zjs/pull/8) |

说明：上游 PR #8 的作者明确写明在 M1136 上测试；`MX=16` 偶发乱码，`MX=0` 正常。该补丁已于 2026-06-25 合并。因此 M1136 同时具有本地实测与上游用户实测证据，但 README 中仍应以“本项目实测 M1136”作为最强、最清楚的表述。

### B. 上游明确列为 foo2xqx 支持目标，但本项目未验证

下列型号存在于上游 `foo2xqx` 支持列表、驱动映射和型号 PPD/设备数据库中。这里的“上游支持”表示代码与配置明确覆盖，**不等于 OpenPrinting 维护者对每台真机做过验证，也不等于当前 M1136 安装器会自动配置它们**。

| 型号 | 上游状态 | 本项目建议 |
|---|---|---|
| HP LaserJet M1005 MFP | `foo2xqx` 明确列出 | 高优先级独立适配/真机验证 |
| HP LaserJet M1120 MFP | `foo2xqx` 明确列出 | 高优先级独立适配/真机验证 |
| HP LaserJet P2014 / P2014n | `foo2xqx` 明确列出 | 高优先级独立适配/真机验证；分别确认 USB/网络 URI |
| HP LaserJet Pro M1132s MFP | `foo2xqx` 明确列出并有专用 PPD | 与 M1136 最接近的优先候选，但仍需真机测试 |
| HP LaserJet Pro M1212nf MFP | `foo2xqx` 明确列出并有专用 PPD | 高优先级；USB 与以太网均应分别验证 |

一手证据：

- [OpenPrinting/foo2zjs README：FOO2XQX 型号列表](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/README)
- [foo2xqx 驱动数据库映射](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/foomatic-db/driver/foo2xqx.xml)
- [上游 ChangeLog](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/ChangeLog)：记录 M1120、P2014、M1212nf 等加入 `foo2xqx`
- [foo2xqx 手册页源文件](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/foo2xqx.1in)
- [HP M1212nf 官方规格](https://support.hp.com/ca-en/product/product-specs/hp-laserjet-pro-m1212nf-multifunction-printer-series/3965848)：明确为 host-based 打印语言

### C. 同系列/同协议，可能兼容；必须视为未验证

| 型号 | 为什么可能兼容 | 为什么不能标成已支持 |
|---|---|---|
| HP LaserJet Pro M1132 MFP | HP 将它与 M1136 放在 M1130 系列共同手册/支持范围；M1132s 已在上游 `foo2xqx` 列表 | 上游条目名称是 M1132s；当前包 USB 字符串与 PPD 固定为 M1136 |
| HP LaserJet Pro M1139 MFP | HP 官方将其与 M1132/M1136 同列为 M1130 系列 | 上游无专用 M1139 映射/PPD，本项目无真机测试 |
| HP LaserJet Pro M1213nf / M1214nfh / M1216nfh / M1217nfw / M1218nfs / M1219nf | HP 官方将它们与 M1212nf 同列为 M1210 系列；上游 PR #8 说明 `foo2xqx` 用于 M1130/M1210 系列 | 上游当前只明确映射 M1212nf；网络、Wi‑Fi、传真/扫描能力和 Device ID 各异，必须逐型号验证 |

一手证据：

- [HP 官方 M1130/M1210 系列型号清单](https://support.hp.com/in-en/document/c02003606)：列出 M1132、M1132s、M1136、M1139、M1212nf、M1213nf、M1214nfh、M1216nfh、M1217nfw、M1218nfs、M1219nf
- [HP 官方 M1130/M1210 用户指南入口](https://support.hp.com/us-en/product/setup-user-guides/hp-laserjet-pro-m1132-multifunction-printer-series/model/3965842)
- [HP 官方 M1130/M1210 Software Technical Reference（PDF）](https://h10032.www1.hp.com/ctg/Manual/c01996678.pdf)
- [上游 PR #8](https://github.com/OpenPrinting/foo2zjs/pull/8)：补丁作者称 `foo2xqx` 用于 LaserJet Pro M1130/M1210 MFP 系列；这是有价值的技术证据，但不能替代每个地区型号的真机测试

### D. 上游支持但需要固件，当前包应标为实验性/不即装即用

| 型号 | 协议 | 额外条件 | 当前包结论 |
|---|---|---|---|
| HP LaserJet P1005 | XQX | 每次上电需加载 `sihpP1005` 固件；特殊 600×400 模式 | 实验性；当前包不含固件加载流程 |
| HP LaserJet P1006 | XQX | 每次上电需加载 `sihpP1006` 固件；特殊 600×400 模式 | 实验性；当前包不含固件加载流程 |
| HP LaserJet P1007 | XQX | 使用 P1005 固件别名；特殊 600×400 模式 | 实验性；当前包不含固件加载流程 |
| HP LaserJet P1008 | XQX | 使用 P1006 固件别名；特殊 600×400 模式 | 实验性；当前包不含固件加载流程 |
| HP LaserJet P1505 / P1505n | XQX | 上游有 `sihpP1505` 固件加载机制 | 实验性；网络版是否已持久化固件也需逐机确认 |

一手证据：

- [上游 macOS 安装说明](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/INSTALL.osx)：明确说明 HP LaserJet 10xx 每次开机需发送固件，并列出 P1005/P1006/P1505 固件
- [上游固件热插拔脚本](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/hplj1000)：列出 P1005/P1006/P1007/P1008/P1505，且 P1007→P1005、P1008→P1006
- [上游 ChangeLog](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/ChangeLog)：P1005–P1009 不能按其他 XQX 型号使用真正 600×600，需要 ReducedResolution 的 600×400 模式
- [HP P1005 官方规格](https://support.hp.com/us-en/product/product-specs/hp-laserjet-p1005-printer/3435674)：host-based 打印、USB 2.0

固件还涉及再分发许可与来源审查。在许可没有确认前，不应把 HP 固件直接塞进公开 Git 仓库或安装包。

### E. 当前 M1136 安装包不支持；只能另做适配

#### HP：不同 foo2zjs/ZjStream 变体

- HP LaserJet Pro P1102/P1102w、P1566、P1606dn 使用 `foo2zjs-z2`，不是 `foo2xqx`。
- HP LaserJet 1000/1005/1018/1020/1022、M1319 MFP、P2035/P2035n 等属于其他 `foo2zjs` 变体；其中多款也有固件要求。
- HP Color LaserJet 1500、1600、2600n、CP1215、CP1025nw 等使用 OAKT、foo2hp 或其他路径，并涉及彩色配置。

#### 其他厂商：不同协议

OpenPrinting/foo2zjs 上游还列出 Konica Minolta/Minolta、Samsung、Xerox/Fuji Xerox、Oki、Dell、Epson、Ricoh、Kyocera、Lexmark、Olivetti 等型号，但分别使用 LAVAFLOW、QPDL、HIPERC、HBPL2、DDST、OAKT、SLX 等协议。它们可以作为未来 Apple Silicon/macOS 封装工作的候选，**不能宣传为 M1136 包的可能兼容机型**。

一手证据：

- [OpenPrinting/foo2zjs README 的协议—型号分组](https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/README)
- [OpenPrinting/foo2zjs 上游仓库](https://github.com/OpenPrinting/foo2zjs)

## macOS 范围与上游维护状态

- Apple 的 HP Printer Drivers 5.1.1 官方页面明确写明：**不兼容 macOS 12 及以上**。因此不能用旧 Apple/HP 驱动包的型号表来证明 macOS 26 支持。[Apple 官方页面](https://support.apple.com/en-us/106385)
- OpenPrinting 关于建立 foo2zjs 仓库的讨论中，维护者明确表示该仓库主要用于代码共享，维护者没有这些打印机来逐机实现/测试/验证，依赖打印机拥有者提交补丁。因此 README 必须区分“上游有配置”与“本项目真机验证”。[OpenPrinting/CUPS discussion #1276](https://github.com/OpenPrinting/cups/discussions/1276)
- 当前成果验证的是**打印路径**，不是扫描、复印、传真或设备状态监控。复印是设备本地功能；扫描/传真需要独立驱动或应用，不能由 foo2xqx 打印成功推导出来。

## 推荐 README 用语

建议最终双语 README 使用以下三层，而不要写宽泛的 “supports many printers”：

1. **Tested / 已测试**：HP LaserJet Professional M1136 MFP — Apple Silicon, macOS 26, USB printing.
2. **Upstream candidates / 上游候选**：列出 M1005、M1120、P2014/P2014n、M1132s、M1212nf，并明确“需要型号专用配置，尚未由本项目验证；当前安装器不会自动安装这些型号”。
3. **Experimental / 实验性**：M1130/M1210 其他地区型号，以及 P1005/P1006/P1007/P1008/P1505 系列；后一组必须额外标注 firmware required。

建议加入醒目免责声明：

> 中文：本安装包目前仅在 HP LaserJet Professional M1136 MFP 上完成真机验证。表中“可能兼容”仅表示上游协议或产品系列相近，不代表本项目已测试，也不保证安装器能够自动识别。当前版本仅处理打印，不提供扫描/传真驱动。
>
> English: This package has been hardware-tested only with the HP LaserJet Professional M1136 MFP. “Potentially compatible” means that an upstream driver mapping or a closely related product family exists; it does not mean that this project has tested the model or that the installer can configure it automatically. The current release provides printing only, not scanner or fax drivers.

## 后续逐型号验收门槛

每个新增型号至少应满足以下条件后，才从“候选/实验性”升级为“已测试”：

1. 保存 `system_profiler SPUSBDataType` 与 CUPS USB backend 返回的实际设备名/URI（公开时删除序列号）。
2. 使用该型号专用 IEEE-1284 Device ID 与 PPD，避免沿用 M1136 名称冒充。
3. 在 Apple Silicon + 目标 macOS 版本执行：单页、中文/英文 PDF、多页、A4、Letter、取消作业、断电重连。
4. 检查 CUPS 日志无 filter/backend error，并确认真实出纸内容正确、无乱码/裁切。
5. 固件型设备另测冷启动后自动加载、重复插拔、许可与离线安装。
6. 网络型号分别测试 USB 与网络打印；扫描/传真另立项目，不能跟随打印状态一起宣称支持。
