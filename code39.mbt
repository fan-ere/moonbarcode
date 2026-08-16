///|
/// Code 39 字符集（不含起始/终止符 `*`），下标即 mod-43 校验值。
let code39_charset : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"

///|
/// Code 39 字符到 9 位模式的映射（1=宽元素，0=窄元素；元素按 条-空-条-空 交替）。
let code39_patterns : Array[String] = [
  "000110100", // 0
   "100100001", // 1
   "001100001", // 2
   "101100000", // 3
   "000110001", // 4
   "100110000", // 5
   "001110000", // 6
   "000100101", // 7
   "100100100", // 8
   "001100100", // 9
   "100001001", // A
   "001001001", // B
   "101001000", // C
   "000011001", // D
   "100011000", // E
   "001011000", // F
   "000001101", // G
   "100001100", // H
   "001001100", // I
   "000011100", // J
   "100000011", // K
   "001000011", // L
   "101000010", // M
   "000010011", // N
   "100010010", // O
   "001010010", // P
   "000000111", // Q
   "100000110", // R
   "001000110", // S
   "000010110", // T
   "110000001", // U
   "011000001", // V
   "111000000", // W
   "010010001", // X
   "110010000", // Y
   "011010000", // Z
   "010000101", // -
   "110000100", // .
   "011000100", // space
   "010101000", // $
   "010100010", // /
   "010001010", // +
   "000101010", // %
]

///|
/// 起始/终止符 `*` 的模式。
let code39_star : String = "010010100"

///|
/// 返回字符在 Code 39 字符集中的下标（即 mod-43 校验值），`*` 不可作为数据。
fn code39_value(c : Byte) -> Int? {
  let cs = @utf8.encode(code39_charset)
  for i = 0; i < cs.length(); i = i + 1 {
    if cs[i] == c {
      return Some(i)
    }
  }
  None
}

///|
/// 计算 Code 39 mod-43 校验值（数据不含起始/终止符）。
pub fn code39_checksum(data : String) -> Result[Int, String] {
  let b = @utf8.encode(data)
  if b.length() == 0 {
    return Err("Code 39 data must not be empty")
  }
  let mut sum = 0
  for i = 0; i < b.length(); i = i + 1 {
    match code39_value(b[i]) {
      None => return Err("Code 39 data contains unsupported character")
      Some(v) => sum = sum + v
    }
  }
  Ok(sum % 43)
}

///|
/// 编码 Code 39。
///
/// `data` 使用 43 字符基本字符集（`*` 除外）；`with_checksum` 为 true 时自动
/// 追加 mod-43 校验字符。输出模块数 = `16 * N + 31`（N 为数据字符数）。
pub fn encode_code39(
  data : String,
  with_checksum? : Bool = false,
) -> Result[Barcode, EncodeError] {
  let b = @utf8.encode(data)
  if b.length() == 0 {
    return Err(InvalidData("Code 39 data must not be empty"))
  }
  let values : Array[Int] = []
  for i = 0; i < b.length(); i = i + 1 {
    match code39_value(b[i]) {
      None =>
        return Err(
          InvalidData(
            "Code 39 data contains unsupported character at position \{i}",
          ),
        )
      Some(v) => values.push(v)
    }
  }
  let mut payload = data
  if with_checksum {
    match code39_checksum(data) {
      Err(msg) => return Err(InvalidData(msg))
      Ok(check) => {
        let cs = @utf8.encode(code39_charset)
        payload = data + cs[check].to_char().to_string()
        values.push(check)
      }
    }
  }
  let modules : Array[Bool] = []
  append_code39_char(modules, code39_star)
  for v in values {
    modules.push(false) // 字符间窄空
    append_code39_char(modules, code39_patterns[v])
  }
  modules.push(false)
  append_code39_char(modules, code39_star)
  Ok({ symbology: Code39, data: payload, modules })
}

///|
/// 将一个 Code 39 字符模式展开为模块：宽元素 3 模块，窄元素 1 模块。
fn append_code39_char(modules : Array[Bool], pattern : String) -> Unit {
  let p = @utf8.encode(pattern)
  for i = 0; i < p.length(); i = i + 1 {
    let is_bar = i % 2 == 0
    let width = if p[i] == b'1' { 3 } else { 1 }
    for _ in 0..<width {
      modules.push(is_bar)
    }
  }
}

///|
/// 校验 Code 39 数据是否可编码（字符集检查，不含校验位要求）。
pub fn validate_code39(data : String) -> Result[Unit, EncodeError] {
  match encode_code39(data) {
    Err(e) => Err(e)
    Ok(_) => Ok(())
  }
}
