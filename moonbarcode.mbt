///|
/// moonbarcode —— 纯 MoonBit 原生的一维条码生成、校验与渲染工具库。
///
/// 设计目标：
/// - 零外部依赖、零 FFI，同一套代码可编译到 native / wasm / wasm-gc / js；
/// - 符号体系按标准实现（ISO/IEC 15420、16388、15417、GS1 通用规范）；
/// - 编码、校验、渲染分层，便于测试与扩展。
///
/// 当前实现进度：
/// - 零售条码：EAN-13、EAN-8、UPC-A（UPC-E 规划中）
/// - 出版物校验：ISBN-10 / ISBN-13、ISSN、GTIN-14
/// - 物流与工业：Code 39、Code 93、Code 128（含 GS1-128）、ITF-14
/// - 渲染：SVG、ASCII、ANSI
/// - CLI：encode / validate / list / info
