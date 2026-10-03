# 在新版 macOS 上使用 HP LaserJet M1136

简体中文 | [English](README.md)

这是一个非官方、开源的 **HP LaserJet Professional M1136 MFP** 打印解决方案。它用 Ghostscript 和 OpenPrinting `foo2zjs` 项目的 `foo2xqx`，替代已经无法在新版 macOS 上正常工作的 HP 旧版 host-based 打印链路。

## 我们实际解决并测试的机型

- 打印机：HP LaserJet Professional M1136 MFP，USB 直连
- 电脑：Apple Silicon（`arm64`），macOS 26.1
- 结果：连续两次 macOS 测试页打印成功，A4 / 1200×600 dpi
- 范围：**仅打印**，不安装也不承诺扫描功能
- 安装包：1.1.0，社区构建，未签名

只有 M1136 是本项目实际测试通过的机型。下面的相近型号是调研线索，不代表这个为 M1136 定制的安装包会自动配置它们。

## 下载和安装

1. 下载 [`HP-LaserJet-M1136-macOS26-arm64.pkg`](dist/HP-LaserJet-M1136-macOS26-arm64.pkg)。
2. 对照 [`checksums/SHA256SUMS`](checksums/SHA256SUMS) 验证 SHA-256。
3. 用 USB 连接 M1136、打开打印机电源，再以管理员身份运行安装包。
4. 如果安装时打印机没有连接，之后连接好并执行：

   ```sh
   sudo /Library/Printers/hp-m1136/configure-printer.sh
   ```

新版安装包在打印机未连接时也会正常完成：驱动文件已经装好，只推迟创建打印队列。这样就不会再把“未连接或未开机”误报成安装失败。

安装包尚未签名或公证，请先查看源码并核对校验值。它只写入 `/Library/Printers/hp-m1136`，创建 `HP_LaserJet_M1136` CUPS 队列；驱动不会上传打印内容，也不会连接网络服务。

## 可能适配的型号

| 状态 | 型号 | 含义 |
|---|---|---|
| ✅ 本项目实测 | **HP LaserJet Professional M1136 MFP** | 本仓库的安装包和队列配置已经实机验证 |
| 🟡 上游明确的 `foo2xqx` 候选 | HP LaserJet M1005 MFP、M1120 MFP、P2014/P2014n、M1132s MFP、M1212nf MFP | 上游明确映射到同一转换器，但本项目未测试；每个型号仍需专用 PPD、USB 匹配和安装器 |
| 🟡 同产品系列，未验证 | HP LaserJet Pro M1132、M1139、M1213nf/M1214nfh/M1216nfh/M1217nfw/M1218nfs/M1219nf | HP 将它们列入相关 M1130/M1210 系列，但上游没有为每个地区型号提供独立映射 |
| 🧪 依赖固件的 `foo2xqx` 候选 | HP LaserJet P1005/P1006/P1007/P1008、P1505/P1505n | 每次开机后需要厂商固件；P1005–P1009 还有特殊 600×400 模式。本项目不包含固件 |
| ❌ 不同驱动链路 | HP P1102/P1102w/P1566/P1606dn、旧款 10xx/1022、P2035 系列及 HP 彩色机型 | 上游使用其他 ZjStream 变体、OAKT、`foo2hp` 或其他路径，需要另做安装包 |

上游 `foo2zjs` 还包含部分 Dell、Epson、Fuji Xerox、Konica Minolta、Kyocera、Lexmark、Minolta、Oki、Samsung 和 Xerox 型号的 PPD，但它们使用其他协议。**它们不兼容当前 M1136 包，需要另做安装包。** 尝试移植前请阅读 [`docs/COMPATIBILITY.md`](docs/COMPATIBILITY.md)。

## 解决原理

M1136 是 USB host-based 打印机，不是原生 PostScript、PCL 或 AirPrint 打印机。实际工作的链路是：

```text
应用程序 → CUPS PDF → 内置 Ghostscript → PBM 光栅 → foo2xqx → XQX 数据流 → USB 打印机
```

这里使用的 `foo2xqx` 已包含上游 `MX=0` 修复；该修复用于解决 M1136 偶发乱码。运行时放在 `/Library/Printers`，以适应新版 macOS 对 CUPS 过滤器的执行限制。

## 日志和排查

确认系统能通过 USB 看到打印机：

```sh
system_profiler SPUSBDataType | grep -A 12 -i 'M1136'
```

查看本项目日志和系统安装日志：

```sh
tail -n 100 /var/log/hp-m1136-driver-install.log
tail -n 200 /var/log/install.log
```

查看打印队列：

```sh
lpstat -t
```

报告其他机型时，请提供型号、macOS 版本、Mac 架构、USB 或网络连接方式、可获得时的 IEEE-1284 `CMD` 值，以及测试结果。**发日志前务必删除序列号、用户名、令牌和私人路径。**

## 来源、隐私和许可证

- 驱动源码：[OpenPrinting/foo2zjs](https://github.com/OpenPrinting/foo2zjs)，提交 `80499ed5bf6caa2963ad337e37cfda78a80aab1e`
- 运行时打包参考：[ardabeh/hp-legacy-mac](https://github.com/ardabeh/hp-legacy-mac)，提交 `fff005c`
- 内置 Ghostscript：10.07.1
- 本次构建使用的上游运行时归档 SHA-256：`60c133b5a53fcce4a4364e1da53d8815cf6b14549e4eba2e88f567fdb6ee950b`

发布前已扫描仓库和安装包，不会主动包含本机用户名、用户目录、打印机序列号、机器标识、凭据、令牌或安装日志。

项目胶水代码和源自 `foo2zjs` 的文件按 GPL-2.0 发布，见 [`LICENSE`](LICENSE) 和 [`LICENSES/GPL-2.0.txt`](LICENSES/GPL-2.0.txt)。Ghostscript 按 AGPL-3.0-or-later 发布，见 [`LICENSES/AGPL-3.0.txt`](LICENSES/AGPL-3.0.txt) 与 [`THIRD_PARTY.md`](THIRD_PARTY.md)。本项目与 HP、Apple、OpenPrinting、Artifex 均无隶属关系，不提供任何担保。
