// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "fan-ere/moonbarcode"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/fan-ere/moonbarcode"

license = "Apache-2.0"

keywords = [
  "barcode",
  "ean",
  "upc",
  "code128",
  "code39",
  "code93",
  "isbn",
  "itf",
  "gs1",
  "svg",
  "wasm",
]

preferred_target = "wasm"

description = "纯 MoonBit 原生的一维条码（1D barcode）生成、校验与渲染工具库：EAN-13 / EAN-8 / UPC-A / Code 39 / Code 93 / Code 128 / ITF-14 编码、ISBN / ISSN / GTIN 校验、SVG / ASCII / ANSI 渲染，可编译为 native / wasm / wasm-gc / js 多后端。"

import {
  "moonbitlang/async@0.20.5",
}
