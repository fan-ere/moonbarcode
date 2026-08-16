///|
/// Code 128 的 107 个图案（0-105 为 11 模块，106 停止符为 13 模块）。
///
/// 表格由 `scripts/gen_code128_table.py` 依据 ZXing `Code128Reader#CODE_PATTERNS`
/// 的条空宽度数组生成（图案本身为公开标准数据）。
let code128_patterns : Array[String] = [
  "11011001100", // 0
   "11001101100", // 1
   "11001100110", // 2
   "10010011000", // 3
   "10010001100", // 4
   "10001001100", // 5
   "10011001000", // 6
   "10011000100", // 7
   "10001100100", // 8
   "11001001000", // 9
   "11001000100", // 10
   "11000100100", // 11
   "10110011100", // 12
   "10011011100", // 13
   "10011001110", // 14
   "10111001100", // 15
   "10011101100", // 16
   "10011100110", // 17
   "11001110010", // 18
   "11001011100", // 19
   "11001001110", // 20
   "11011100100", // 21
   "11001110100", // 22
   "11101101110", // 23
   "11101001100", // 24
   "11100101100", // 25
   "11100100110", // 26
   "11101100100", // 27
   "11100110100", // 28
   "11100110010", // 29
   "11011011000", // 30
   "11011000110", // 31
   "11000110110", // 32
   "10100011000", // 33
   "10001011000", // 34
   "10001000110", // 35
   "10110001000", // 36
   "10001101000", // 37
   "10001100010", // 38
   "11010001000", // 39
   "11000101000", // 40
   "11000100010", // 41
   "10110111000", // 42
   "10110001110", // 43
   "10001101110", // 44
   "10111011000", // 45
   "10111000110", // 46
   "10001110110", // 47
   "11101110110", // 48
   "11010001110", // 49
   "11000101110", // 50
   "11011101000", // 51
   "11011100010", // 52
   "11011101110", // 53
   "11101011000", // 54
   "11101000110", // 55
   "11100010110", // 56
   "11101101000", // 57
   "11101100010", // 58
   "11100011010", // 59
   "11101111010", // 60
   "11001000010", // 61
   "11110001010", // 62
   "10100110000", // 63
   "10100001100", // 64
   "10010110000", // 65
   "10010000110", // 66
   "10000101100", // 67
   "10000100110", // 68
   "10110010000", // 69
   "10110000100", // 70
   "10011010000", // 71
   "10011000010", // 72
   "10000110100", // 73
   "10000110010", // 74
   "11000010010", // 75
   "11001010000", // 76
   "11110111010", // 77
   "11000010100", // 78
   "10001111010", // 79
   "10100111100", // 80
   "10010111100", // 81
   "10010011110", // 82
   "10111100100", // 83
   "10011110100", // 84
   "10011110010", // 85
   "11110100100", // 86
   "11110010100", // 87
   "11110010010", // 88
   "11011011110", // 89
   "11011110110", // 90
   "11110110110", // 91
   "10101111000", // 92
   "10100011110", // 93
   "10001011110", // 94
   "10111101000", // 95
   "10111100010", // 96
   "11110101000", // 97
   "11110100010", // 98
   "10111011110", // 99
   "10111101110", // 100
   "11101011110", // 101
   "11110101110", // 102
   "11010000100", // 103
   "11010010000", // 104
   "11010011100", // 105
   "1100011101011", // 106
]

///|
/// 起始码 A（103）/ B（104）/ C（105）、切换码、FNC1 等常量。
let code128_start_a : Int = 103

///|
let code128_start_b : Int = 104

///|
let code128_start_c : Int = 105

///|
let code128_stop : Int = 106

///|
let code128_code_c : Int = 99

///|
let code128_code_b : Int = 100

///|
let code128_code_a : Int = 101

///|
let code128_fnc1 : Int = 102

///|
/// 判断字节是否为 ASCII 数字。
fn is_ascii_digit(c : Byte) -> Bool {
  c >= b'0' && c <= b'9'
}

///|
/// 从位置 `pos` 开始统计连续数字的个数。
fn digit_run(b : Bytes, pos : Int) -> Int {
  let mut n = 0
  let mut i = pos
  while i < b.length() && is_ascii_digit(b[i]) {
    n = n + 1
    i = i + 1
  }
  n
}

///|
/// 将数据编码为 Code 128 值序列（含子集切换，不含起始码与校验码）。
/// 返回 (values, start_code)。起始码按首个字符段选择 A/B/C。
fn code128_values(data : String) -> Result[(Array[Int], Int), String] {
  let b = @utf8.encode(data)
  if b.length() == 0 {
    return Err("Code 128 data must not be empty")
  }
  for i = 0; i < b.length(); i = i + 1 {
    let n = b[i].to_int()
    if n > 127 {
      return Err("Code 128 supports ASCII characters only")
    }
  }
  let values : Array[Int] = []
  let mut pos = 0
  let mut mode : Int? = None
  while pos < b.length() {
    let run = digit_run(b, pos)
    if run >= 4 && pos + 1 < b.length() {
      // 进入/保持 Code C，按两位一组消费偶数个数字。
      match mode {
        Some(m) if m == code128_start_c => ()
        None => mode = Some(code128_start_c)
        Some(_) => {
          values.push(code128_code_c)
          mode = Some(code128_start_c)
        }
      }
      let pairs = if run % 2 == 0 { run } else { run - 1 }
      let mut consumed = 0
      while consumed < pairs {
        let v = (b[pos] - b'0').to_int() * 10 + (b[pos + 1] - b'0').to_int()
        values.push(v)
        pos = pos + 2
        consumed = consumed + 2
      }
      if pairs < run {
        // 奇数位剩余 1 个数字：切回 B 编码该位。
        match mode {
          Some(m) if m == code128_start_b => ()
          None => mode = Some(code128_start_b)
          Some(_) => {
            values.push(code128_code_b)
            mode = Some(code128_start_b)
          }
        }
        values.push(b[pos].to_int() - 32)
        pos = pos + 1
      }
    } else {
      let n = b[pos].to_int()
      if n < 32 {
        // 控制字符只能编码在 Code A。
        match mode {
          Some(m) if m == code128_start_a => ()
          None => mode = Some(code128_start_a)
          Some(_) => {
            values.push(code128_code_a)
            mode = Some(code128_start_a)
          }
        }
        values.push(n + 64)
      } else {
        // 可打印字符（32-127）默认 Code B；若处于 C 则切换。
        match mode {
          Some(m) if m == code128_start_b => ()
          Some(m) if m == code128_start_a => ()
          None => mode = Some(code128_start_b)
          Some(_) => {
            values.push(code128_code_b)
            mode = Some(code128_start_b)
          }
        }
        values.push(n - 32)
      }
      pos = pos + 1
    }
  }
  let start = match mode {
    None => code128_start_b
    Some(m) => m
  }
  Ok((values, start))
}

///|
/// 计算 Code 128 校验值（mod-103，含起始码，权重从 1 递增）。
pub fn code128_checksum(
  data : String,
  gs1? : Bool = false,
) -> Result[Int, String] {
  match code128_values(data) {
    Err(msg) => Err(msg)
    Ok((values, start)) => {
      let mut total = start
      if gs1 {
        total = total + code128_fnc1 * 1
      }
      for i = 0; i < values.length(); i = i + 1 {
        total = total + values[i] * (i + 1)
      }
      Ok(total % 103)
    }
  }
}

///|
/// 编码 Code 128（含子集 A/B/C 自动选择）。
///
/// `gs1` 为 true 时生成 GS1-128：起始码后紧跟 FNC1。
/// 输出结构：起始码 + 数据（含子集切换）+ [FNC1] + 校验码 + 停止符（13 模块）。
pub fn encode_code128(
  data : String,
  gs1? : Bool = false,
) -> Result[Barcode, EncodeError] {
  match code128_values(data) {
    Err(msg) => Err(InvalidData(msg))
    Ok((values, start)) => {
      let mut total = start
      if gs1 {
        total = total + code128_fnc1
      }
      for i = 0; i < values.length(); i = i + 1 {
        total = total + values[i] * (i + 1)
      }
      let check = total % 103
      let modules : Array[Bool] = []
      append_code128_pattern(modules, code128_patterns[start])
      if gs1 {
        append_code128_pattern(modules, code128_patterns[code128_fnc1])
      }
      for v in values {
        append_code128_pattern(modules, code128_patterns[v])
      }
      append_code128_pattern(modules, code128_patterns[check])
      append_code128_pattern(modules, code128_patterns[code128_stop])
      Ok({ symbology: Code128, data, modules })
    }
  }
}

///|
/// 追加一个 Code 128 图案（11 或 13 模块）。
fn append_code128_pattern(modules : Array[Bool], pattern : String) -> Unit {
  let p = @utf8.encode(pattern)
  for i = 0; i < p.length(); i = i + 1 {
    modules.push(p[i] == b'1')
  }
}

///|
/// 校验 Code 128 数据是否可编码。
pub fn validate_code128(
  data : String,
  gs1? : Bool = false,
) -> Result[Unit, EncodeError] {
  match encode_code128(data, gs1~) {
    Err(e) => Err(e)
    Ok(_) => Ok(())
  }
}
