///|
/// 支持的条码符号体系。
pub(all) enum Symbology {
  EAN13
  EAN8
  UPCA
  Code39
  Code93
  Code128
  ITF14
} derive(Eq, Debug)

///|
/// 条码的规范表示：一系列明/暗模块（暗=条，明=空）加可读文本。
pub struct Barcode {
  symbology : Symbology
  data : String
  modules : Array[Bool]
}

///|
/// 渲染选项，供 SVG / ASCII / ANSI 渲染器共用。
pub struct BarcodeOptions {
  /// 每个模块的像素/字符宽度。
  module_width : Int
  /// 条高（像素，SVG 使用；ASCII 渲染器忽略）。
  height : Int
  /// 静区宽度（模块数），两侧各留 `quiet_zone` 个模块。
  quiet_zone : Int
  /// 是否在条码下方输出人类可读文本。
  show_text : Bool
  /// 文本与条之间的间距（像素，SVG 使用）。
  text_margin : Int
}

///|
pub fn BarcodeOptions::default() -> BarcodeOptions {
  BarcodeOptions::new()
}

///|
/// 用可选参数构造渲染选项。
pub fn BarcodeOptions::new(
  module_width? : Int = 2,
  height? : Int = 40,
  quiet_zone? : Int = 10,
  show_text? : Bool = true,
  text_margin? : Int = 12,
) -> BarcodeOptions {
  { module_width, height, quiet_zone, show_text, text_margin }
}

///|
/// 编码或校验过程中产生的错误。
pub(all) enum EncodeError {
  /// 输入数据不符合该符号体系的格式要求。
  InvalidData(String)
  /// 符号体系已识别但尚未实现。
  Unsupported(String)
} derive(Eq, Debug)

///|
/// 返回错误的可读描述。
pub fn error_message(err : EncodeError) -> String {
  match err {
    InvalidData(msg) => "invalid data: \{msg}"
    Unsupported(msg) => "unsupported: \{msg}"
  }
}

///|
/// 条码的模块总数（暗 + 明）。
pub fn Barcode::module_count(self : Barcode) -> Int {
  self.modules.length()
}

///|
/// 条码中暗模块（条）的数量。
pub fn Barcode::bar_count(self : Barcode) -> Int {
  let mut n = 0
  for m in self.modules {
    if m {
      n = n + 1
    }
  }
  n
}
