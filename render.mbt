///|
/// 将一段明/暗模块序列渲染为 SVG。
///
/// 静区（quiet zone）按模块数计，左右各留 `quiet_zone` 个模块；
/// 相邻的暗模块会被合并为一个矩形以减小 SVG 体积。
pub fn render_svg(barcode : Barcode, options : BarcodeOptions) -> String {
  let mw = max_int(options.module_width, 1)
  let qz = max_int(options.quiet_zone, 0)
  let modules = barcode.modules
  let content_width = modules.length() * mw
  let total_width = content_width + 2 * qz * mw
  let bar_height = max_int(options.height, 1)
  let text_height = if options.show_text {
    max_int(options.text_margin, 0) + 14
  } else {
    0
  }
  let total_height = bar_height + text_height
  let out = Buffer()
  out.write_string_utf8(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\{total_width}\" height=\"\{total_height}\" viewBox=\"0 0 \{total_width} \{total_height}\">",
  )
  out.write_string_utf8(
    "<rect width=\"100%\" height=\"100%\" fill=\"#ffffff\"/>",
  )
  out.write_string_utf8("<g fill=\"#000000\">")
  let mut x = qz * mw
  let mut i = 0
  while i < modules.length() {
    if modules[i] {
      let start = i
      while i < modules.length() && modules[i] {
        i = i + 1
      }
      let run = i - start
      out.write_string_utf8(
        "<rect x=\"\{x}\" y=\"0\" width=\"\{run * mw}\" height=\"\{bar_height}\"/>",
      )
      x = x + run * mw
    } else {
      x = x + mw
      i = i + 1
    }
  }
  out.write_string_utf8("</g>")
  if options.show_text {
    let cx = total_width / 2
    let ty = bar_height + max_int(options.text_margin, 0) + 12
    out.write_string_utf8(
      "<text x=\"\{cx}\" y=\"\{ty}\" text-anchor=\"middle\" font-family=\"monospace\" font-size=\"14\">\{xml_escape(barcode.data)}</text>",
    )
  }
  out.write_string_utf8("</svg>")
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// 渲染为单行 ASCII 预览（暗模块为 `#`，明模块为空格）。
/// 每个模块按 `module_width` 重复，便于肉眼检查。
pub fn render_ascii(barcode : Barcode, options : BarcodeOptions) -> String {
  let mw = max_int(options.module_width, 1)
  let qz = max_int(options.quiet_zone, 0)
  let out = Buffer()
  for _ in 0..<(qz * mw) {
    out.write_string_utf8(" ")
  }
  for m in barcode.modules {
    let ch = if m { "#" } else { " " }
    for _ in 0..<mw {
      out.write_string_utf8(ch)
    }
  }
  for _ in 0..<(qz * mw) {
    out.write_string_utf8(" ")
  }
  if options.show_text {
    out.write_string_utf8("\n")
    out.write_string_utf8(barcode.data)
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// 渲染为 ANSI 反白预览（暗模块为反白块，适配多数终端）。
pub fn render_ansi(barcode : Barcode, options : BarcodeOptions) -> String {
  let mw = max_int(options.module_width, 1)
  let qz = max_int(options.quiet_zone, 0)
  let out = Buffer()
  for _ in 0..<(qz * mw) {
    out.write_string_utf8(" ")
  }
  for m in barcode.modules {
    for _ in 0..<mw {
      if m {
        out.write_byte(27)
        out.write_string_utf8("[7m ")
        out.write_byte(27)
        out.write_string_utf8("[0m")
      } else {
        out.write_string_utf8(" ")
      }
    }
  }
  for _ in 0..<(qz * mw) {
    out.write_string_utf8(" ")
  }
  if options.show_text {
    out.write_string_utf8("\n")
    out.write_string_utf8(barcode.data)
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// 转义 XML 特殊字符。
fn xml_escape(s : String) -> String {
  let b = @utf8.encode(s)
  let out = Buffer()
  for i = 0; i < b.length(); i = i + 1 {
    let c = b[i]
    if c == b'&' {
      out.write_string_utf8("&amp;")
    } else if c == b'<' {
      out.write_string_utf8("&lt;")
    } else if c == b'>' {
      out.write_string_utf8("&gt;")
    } else {
      out.write_byte(c)
    }
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// 返回两个整数中的较大者。
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
