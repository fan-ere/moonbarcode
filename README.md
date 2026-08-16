# moonbarcode

[![CI](https://github.com/fan-ere/moonbarcode/actions/workflows/ci.yml/badge.svg)](https://github.com/fan-ere/moonbarcode/actions/workflows/ci.yml)

纯 MoonBit 原生的一维条码（1D barcode）生成、校验与渲染工具库。

目标：补足 MoonBit 生态中一维条码能力的空白（MoonBit 生态目前只有二维 QR 码
实现 [qrc](https://mooncakes.io/packages/bobzhang/qrc)），为零售、物流、
图书、库存、电商标签等场景提供可复用、可编译到多后端的条码基础组件。

## 支持的符号体系（Symbologies）

- 零售：EAN-13、EAN-8、UPC-A（UPC-E 规划中）
- 图书与出版物：ISBN-10 / ISBN-13、ISSN、ISMN、GTIN-14 校验
- 物流与工业：ITF-14、Code 39、Code 93、Code 128（含 GS1-128）

## 渲染

- SVG：适合打印与网页
- ASCII / ANSI：适合终端调试与测试

## 快速开始

```bash
# 编码为 SVG 文件
moon run cmd/main -- encode --type ean13 --data 6901234567892 --out out.svg

# 终端 ASCII 预览
moon run cmd/main -- encode --type ean13 --data 6901234567892 --format ascii

# 校验 ISBN-13
moon run cmd/main -- validate --type isbn13 --data 978-0-306-40615-7
```

库用法（开发中）：

```moonbit
let barcode = @moonbarcode.encode(@moonbarcode.EAN13, "6901234567892")
```

## 开发状态

- [x] 项目脚手架、CI、许可证
- [ ] MVP：EAN-13 / UPC-A / EAN-8 编码 + ISBN/ISSN 校验 + SVG/ASCII 渲染 + CLI
- [ ] Code 39 / Code 93
- [ ] Code 128 / GS1-128
- [ ] ITF-14
- [ ] UPC-E 与补充码（+2 / +5）

## 许可证

Apache-2.0
