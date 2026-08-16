///|
/// EAN-13 L-code（奇校验，左手区）。
let l_code : Array[String] = [
  "0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011",
  "0110111", "0001011",
]

///|
/// EAN-13 G-code（偶校验，左手区，由首数字的奇偶模式选择）。
let g_code : Array[String] = [
  "0100111", "0110011", "0011011", "0100001", "0011101", "0111001", "0000101", "0010001",
  "0001001", "0010111",
]

///|
/// EAN-13 R-code（右手区，与 L-code 逐位取反）。
let r_code : Array[String] = [
  "1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100",
  "1001000", "1110100",
]

///|
/// 首数字对应的左手 6 位奇偶模式（0=L，1=G）。
let ean13_parity : Array[String] = [
  "000000", "001011", "001101", "001110", "010011", "011001", "011100", "010101",
  "010110", "011010",
]

///|
/// 将一个 "01" 模式的字符串追加到模块数组。
fn append_pattern(modules : Array[Bool], pattern : String) -> Unit {
  let p = @utf8.encode(pattern)
  for i = 0; i < p.length(); i = i + 1 {
    modules.push(p[i] == b'1')
  }
}

///|
/// 编码 EAN-13。
///
/// 输入为 12 位（自动追加校验位）或 13 位（校验校验位是否匹配）。
/// 输出 95 个模块。
pub fn encode_ean13(data : String) -> Result[Barcode, EncodeError] {
  if !only_digits_and_separators(data) {
    return Err(
      InvalidData("EAN-13 data must contain only digits and separators"),
    )
  }
  let d = strip_separators(data)
  if d.length() == 12 {
    match mod10_check(d, 1, 3) {
      Err(msg) => return Err(InvalidData(msg))
      Ok(check) => return encode_ean13_fixed(d + check.to_string())
    }
  }
  if d.length() != 13 {
    return Err(
      InvalidData(
        "EAN-13 requires 12 digits (check digit is appended) or 13 digits",
      ),
    )
  }
  if !mod10_verify(d, 1, 3) {
    return Err(InvalidData("EAN-13 check digit mismatch"))
  }
  encode_ean13_fixed(d)
}

///|
/// 按 13 位完整数字（含校验位）生成模块序列。
fn encode_ean13_fixed(digits : String) -> Result[Barcode, EncodeError] {
  if digits.length() != 13 || !is_all_digits(digits) {
    return Err(InvalidData("EAN-13 requires 13 decimal digits"))
  }
  let b = @utf8.encode(digits)
  let first = (b[0] - b'0').to_int()
  let parity = ean13_parity[first]
  let pb = @utf8.encode(parity)
  let modules : Array[Bool] = []
  append_pattern(modules, "101")
  for i = 1; i <= 6; i = i + 1 {
    let v = (b[i] - b'0').to_int()
    let pattern = if pb[i - 1] == b'1' { g_code[v] } else { l_code[v] }
    append_pattern(modules, pattern)
  }
  append_pattern(modules, "01010")
  for i = 7; i < 13; i = i + 1 {
    let v = (b[i] - b'0').to_int()
    append_pattern(modules, r_code[v])
  }
  append_pattern(modules, "101")
  Ok({ symbology: EAN13, data: digits, modules })
}

///|
/// 编码 EAN-8。
///
/// 输入为 7 位（自动追加校验位）或 8 位（校验校验位）。输出 67 个模块。
pub fn encode_ean8(data : String) -> Result[Barcode, EncodeError] {
  if !only_digits_and_separators(data) {
    return Err(
      InvalidData("EAN-8 data must contain only digits and separators"),
    )
  }
  let d = strip_separators(data)
  if d.length() == 7 {
    match mod10_check(d, 3, 1) {
      Err(msg) => return Err(InvalidData(msg))
      Ok(check) => return encode_ean8_fixed(d + check.to_string())
    }
  }
  if d.length() != 8 {
    return Err(
      InvalidData(
        "EAN-8 requires 7 digits (check digit is appended) or 8 digits",
      ),
    )
  }
  if !mod10_verify(d, 3, 1) {
    return Err(InvalidData("EAN-8 check digit mismatch"))
  }
  encode_ean8_fixed(d)
}

///|
/// 按 8 位完整数字（含校验位）生成模块序列。
fn encode_ean8_fixed(digits : String) -> Result[Barcode, EncodeError] {
  if digits.length() != 8 || !is_all_digits(digits) {
    return Err(InvalidData("EAN-8 requires 8 decimal digits"))
  }
  let b = @utf8.encode(digits)
  let modules : Array[Bool] = []
  append_pattern(modules, "101")
  for i = 0; i < 4; i = i + 1 {
    let v = (b[i] - b'0').to_int()
    append_pattern(modules, l_code[v])
  }
  append_pattern(modules, "01010")
  for i = 4; i < 8; i = i + 1 {
    let v = (b[i] - b'0').to_int()
    append_pattern(modules, r_code[v])
  }
  append_pattern(modules, "101")
  Ok({ symbology: EAN8, data: digits, modules })
}

///|
/// 编码 UPC-A。
///
/// 输入为 11 位（自动追加校验位）或 12 位（校验校验位）。
/// UPC-A 等价于首位为 0 的 EAN-13，输出 95 个模块。
pub fn encode_upca(data : String) -> Result[Barcode, EncodeError] {
  if !only_digits_and_separators(data) {
    return Err(
      InvalidData("UPC-A data must contain only digits and separators"),
    )
  }
  let d = strip_separators(data)
  if d.length() == 11 {
    match mod10_check(d, 3, 1) {
      Err(msg) => return Err(InvalidData(msg))
      Ok(check) => return encode_upca_fixed(d + check.to_string())
    }
  }
  if d.length() != 12 {
    return Err(
      InvalidData(
        "UPC-A requires 11 digits (check digit is appended) or 12 digits",
      ),
    )
  }
  if !mod10_verify(d, 3, 1) {
    return Err(InvalidData("UPC-A check digit mismatch"))
  }
  encode_upca_fixed(d)
}

///|
/// 按 12 位完整 UPC-A 数字（含校验位）生成模块序列。
fn encode_upca_fixed(digits : String) -> Result[Barcode, EncodeError] {
  if digits.length() != 12 || !is_all_digits(digits) {
    return Err(InvalidData("UPC-A requires 12 decimal digits"))
  }
  match encode_ean13_fixed("0" + digits) {
    Err(e) => Err(e)
    Ok(b) => Ok({ symbology: UPCA, data: digits, modules: b.modules })
  }
}
