# moonbarcode

[![mooncakes.io](https://img.shields.io/badge/mooncakes.io-fan--ere%2Fmoonbarcode-blue)](https://mooncakes.io/packages/fan-ere/moonbarcode)
[![CI](https://github.com/fan-ere/moonbarcode/actions/workflows/ci.yml/badge.svg)](https://github.com/fan-ere/moonbarcode/actions/workflows/ci.yml)

纯 MoonBit 原生的一维条码（1D barcode）生成、校验与渲染工具库。

目标：补足 MoonBit 生态中一维条码能力的空白（MoonBit 生态目前只有二维 QR 码
实现 [qrc](https://mooncakes.io/packages/bobzhang/qrc)），为零售、物流、
图书、库存、电商标签等场景提供可复用、可编译到多后端的条码基础组件。

## 支持的符号体系（Symbologies）

- 零售：EAN-13、EAN-8、UPC-A
- 物流与工业：Code 39（含 mod-43 校验）、Code 93（C/K 双校验 + Full ASCII）、Code 128（A/B/C 子集自动优化 + GS1-128）、ITF-14
- 图书与出版物校验：ISBN-10 / ISBN-13、ISSN、GTIN-14

## 渲染

- SVG：适合打印与网页
- ASCII / ANSI：适合终端调试与测试

## 快速开始

安装：

```bash
moon add fan-ere/moonbarcode
```

CLI 用法：

```bash
# 编码为 SVG 文件
moon run cmd/main --target native -- encode --type ean13 --data 6901234567892 --out out.svg

# 终端 ASCII 预览
moon run cmd/main --target native -- encode --type ean13 --data 6901234567892 --format ascii

# 校验 ISBN-13
moon run cmd/main --target native -- validate --type isbn13 --data 978-0-306-40615-7
```

CLI 包仅支持 native 目标；本地运行 CLI 需要 C 编译器。核心库仍可在 native / wasm / wasm-gc / js 多后端编译和测试。

最小可运行示例：

```bash
moon run examples/quickstart --target wasm-gc
```

这个示例不依赖 C 编译器，适合先快速验证库的核心 API。

库用法（开发中）：

```moonbit
let barcode = @moonbarcode.encode(@moonbarcode.EAN13, "6901234567892")
```

## 开发状态

- [x] 项目脚手架、CI、许可证
- [x] EAN-13 / UPC-A / EAN-8 编码 + ISBN/ISSN/GTIN 校验 + SVG/ASCII/ANSI 渲染 + CLI
- [x] Code 39（mod-43 校验）
- [x] Code 93（C/K 校验 + Full ASCII）
- [x] Code 128 / GS1-128
- [x] ITF-14
- [x] EAN/UPC、Code 39、ITF-14 模块反解与校验
- [x] GS1 AI 解析、GTIN/SSCC/GLN 与 GS1 日期工具
- [x] 模块序列转换、静区处理与结构分析
- [ ] UPC-E 与补充码（+2 / +5）

## 质量与复现

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt --check .
moon publish --dry-run
```

CI 覆盖 native / wasm-gc / js 三个目标的检查、测试和构建，并包含 native CLI 冒烟测试。

## 来源与合规

项目为原创 MoonBit 实现，未复制第三方条码库源码。标准、编码表和测试样例来源说明见 [docs/SOURCES.md](docs/SOURCES.md)。

## 许可证

Apache-2.0

## 参赛与维护

OSC 2026 申请人与仓库维护者关系见 [docs/PARTICIPATION.md](docs/PARTICIPATION.md)。
