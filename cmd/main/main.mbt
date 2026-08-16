///|
/// moonbarcode CLI。
///
/// 用法：
///   moon run cmd/main -- list
///   moon run cmd/main -- encode --type ean13 --data 6901234567892 [--out out.svg] [--format svg|ascii|ansi]
///   moon run cmd/main -- validate --type ean13 --data 6901234567892
///   moon run cmd/main -- info --type ean13 --data 6901234567892
async fn main {
  let args = @env.args()
  if args.length() < 2 {
    usage()
    return
  }
  match args[1] {
    "list" => list_symbologies()
    "encode" =>
      run_encode(args) catch {
        err => println("moonbarcode: error: \{err.to_string()}")
      }
    "validate" => run_validate(args)
    "info" => run_info(args)
    _ => usage()
  }
}

///|
fn usage() -> Unit {
  println("moonbarcode - MoonBit 原生一维条码工具")
  println("")
  println("用法:")
  println("  moon run cmd/main -- list")
  println("  moon run cmd/main -- encode --type <sym> --data <data> [选项]")
  println(
    "  moon run cmd/main -- validate --type <sym|isbn10|isbn13|issn|gtin14> --data <data>",
  )
  println("  moon run cmd/main -- info --type <sym> --data <data>")
  println("")
  println("encode 选项:")
  println("  --format svg|ascii|ansi   输出格式（默认 svg）")
  println("  --out <path>              写入文件；缺省输出到 stdout")
  println("  --height <n>              条高（默认 40）")
  println("  --module-width <n>        模块宽度（默认 2）")
  println("  --quiet-zone <n>          静区模块数（默认 10）")
  println("  --no-text                 不输出人类可读文本")
}

///|
fn list_symbologies() -> Unit {
  println("已实现:")
  println("  ean13   EAN-13（95 模块，12/13 位）")
  println("  ean8    EAN-8（67 模块，7/8 位）")
  println("  upca    UPC-A（95 模块，11/12 位）")
  println("校验工具:")
  println("  isbn10 / isbn13 / issn / gtin14")
  println("规划中:")
  println("  code39 / code93 / code128 / itf14")
}

///|
async fn run_encode(args : Array[String]) -> Unit {
  let opts = parse_encode_args(args)
  if opts.sym.is_empty() || opts.data.is_empty() {
    println("moonbarcode: encode requires --type and --data")
    return
  }
  match parse_symbology(opts.sym) {
    None => println("moonbarcode: unknown symbology: \{opts.sym}")
    Some(sym) =>
      match @lib.encode(sym, opts.data) {
        Err(e) => println("moonbarcode: \{@lib.error_message(e)}")
        Ok(barcode) => {
          let opt = @lib.BarcodeOptions::new(
            module_width=opts.module_width,
            height=opts.height,
            quiet_zone=opts.quiet_zone,
            show_text=opts.show_text,
          )
          let content = if opts.format == "ascii" {
            @lib.render_ascii(barcode, opt)
          } else if opts.format == "ansi" {
            @lib.render_ansi(barcode, opt)
          } else {
            @lib.render_svg(barcode, opt)
          }
          if opts.out_path.is_empty() {
            println(content)
          } else {
            @fs.write_file(
              opts.out_path,
              content,
              create_mode=@fs.CreateOrTruncate,
            )
            println(
              "moonbarcode: wrote \{content.length()} bytes to \{opts.out_path}",
            )
          }
        }
      }
  }
}

///|
struct EncodeOpts {
  sym : String
  data : String
  format : String
  out_path : String
  height : Int
  module_width : Int
  quiet_zone : Int
  show_text : Bool
}

///|
fn parse_encode_args(args : Array[String]) -> EncodeOpts {
  let mut sym = ""
  let mut data = ""
  let mut format = "svg"
  let mut out_path = ""
  let mut height = 40
  let mut module_width = 2
  let mut quiet_zone = 10
  let mut show_text = true
  let mut i = 2
  while i < args.length() {
    let a = args[i]
    if a == "--type" || a == "-t" {
      i = i + 1
      if i < args.length() {
        sym = args[i]
      }
    } else if a == "--data" || a == "-d" {
      i = i + 1
      if i < args.length() {
        data = args[i]
      }
    } else if a == "--format" || a == "-f" {
      i = i + 1
      if i < args.length() {
        format = args[i]
      }
    } else if a == "--out" || a == "-o" {
      i = i + 1
      if i < args.length() {
        out_path = args[i]
      }
    } else if a == "--height" {
      i = i + 1
      if i < args.length() {
        match parse_int(args[i]) {
          Some(v) => height = v
          None => ()
        }
      }
    } else if a == "--module-width" {
      i = i + 1
      if i < args.length() {
        match parse_int(args[i]) {
          Some(v) => module_width = v
          None => ()
        }
      }
    } else if a == "--quiet-zone" {
      i = i + 1
      if i < args.length() {
        match parse_int(args[i]) {
          Some(v) => quiet_zone = v
          None => ()
        }
      }
    } else if a == "--no-text" {
      show_text = false
    }
    i = i + 1
  }
  { sym, data, format, out_path, height, module_width, quiet_zone, show_text }
}

///|
fn parse_symbology(s : String) -> @lib.Symbology? {
  match s {
    "ean13" => Some(@lib.EAN13)
    "ean8" => Some(@lib.EAN8)
    "upca" => Some(@lib.UPCA)
    "code39" => Some(@lib.Code39)
    "code93" => Some(@lib.Code93)
    "code128" => Some(@lib.Code128)
    "itf14" => Some(@lib.ITF14)
    _ => None
  }
}

///|
fn run_validate(args : Array[String]) -> Unit {
  let mut type_name = ""
  let mut data = ""
  let mut i = 2
  while i < args.length() {
    if args[i] == "--type" {
      i = i + 1
      if i < args.length() {
        type_name = args[i]
      }
    } else if args[i] == "--data" {
      i = i + 1
      if i < args.length() {
        data = args[i]
      }
    }
    i = i + 1
  }
  if type_name.is_empty() || data.is_empty() {
    println("moonbarcode: validate requires --type and --data")
    return
  }
  match type_name {
    "isbn10" =>
      println(if @lib.isbn10_valid(data) { "VALID" } else { "INVALID" })
    "isbn13" =>
      println(if @lib.isbn13_valid(data) { "VALID" } else { "INVALID" })
    "issn" => println(if @lib.issn_valid(data) { "VALID" } else { "INVALID" })
    "gtin14" =>
      println(if @lib.gtin14_valid(data) { "VALID" } else { "INVALID" })
    _ =>
      match parse_symbology(type_name) {
        None => println("moonbarcode: unknown type: \{type_name}")
        Some(sym) =>
          match @lib.validate(sym, data) {
            Err(e) => println("INVALID: \{@lib.error_message(e)}")
            Ok(_) => println("VALID")
          }
      }
  }
}

///|
fn run_info(args : Array[String]) -> Unit {
  let mut type_name = ""
  let mut data = ""
  let mut i = 2
  while i < args.length() {
    if args[i] == "--type" {
      i = i + 1
      if i < args.length() {
        type_name = args[i]
      }
    } else if args[i] == "--data" {
      i = i + 1
      if i < args.length() {
        data = args[i]
      }
    }
    i = i + 1
  }
  if type_name.is_empty() || data.is_empty() {
    println("moonbarcode: info requires --type and --data")
    return
  }
  match parse_symbology(type_name) {
    None => println("moonbarcode: unknown symbology: \{type_name}")
    Some(sym) =>
      match @lib.encode(sym, data) {
        Err(e) => println("moonbarcode: \{@lib.error_message(e)}")
        Ok(barcode) => {
          println("symbology: \{sym_name(sym)}")
          println("data: \{barcode.data}")
          println("modules: \{barcode.module_count()}")
          println("bars: \{barcode.bar_count()}")
          match @lib.checksum(sym, barcode.data) {
            Err(_) => ()
            Ok(c) => println("check digit: \{c}")
          }
        }
      }
  }
}

///|
fn sym_name(s : @lib.Symbology) -> String {
  match s {
    @lib.EAN13 => "EAN-13"
    @lib.EAN8 => "EAN-8"
    @lib.UPCA => "UPC-A"
    @lib.Code39 => "Code 39"
    @lib.Code93 => "Code 93"
    @lib.Code128 => "Code 128"
    @lib.ITF14 => "ITF-14"
  }
}

///|
fn parse_int(s : String) -> Int? {
  let b = @utf8.encode(s)
  if b.length() == 0 {
    return None
  }
  let mut i = 0
  let mut neg = false
  if b[0] == b'-' {
    neg = true
    i = 1
  }
  if i >= b.length() {
    return None
  }
  let mut v = 0
  while i < b.length() {
    let c = b[i]
    if c < b'0' || c > b'9' {
      return None
    }
    v = v * 10 + (c - b'0').to_int()
    i = i + 1
  }
  if neg {
    Some(-v)
  } else {
    Some(v)
  }
}
