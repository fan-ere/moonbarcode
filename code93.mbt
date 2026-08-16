///|
/// Code 93 内部字符集（0-42 为基本字符，43-46 为扩展移位符 a($)/b(%)/c(/)/d(+)，
/// 47 为起始/终止符 `*`）。下标即 mod-47 校验值。
let code93_charset : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%abcd*"

///|
/// Code 93 基本字符集（不含移位符与起始/终止符），用于非 Full-ASCII 模式。
let code93_basic_charset : String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"

///|
/// Code 93 的 48 个 9 模块模式（1=条，0=空），索引与字符集一致。
let code93_patterns : Array[String] = [
  "100010100", // 0
   "101001000", // 1
   "101000100", // 2
   "101000010", // 3
   "100101000", // 4
   "100100100", // 5
   "100100010", // 6
   "101010000", // 7
   "100010010", // 8
   "100001010", // 9
   "110101000", // A
   "110100100", // B
   "110100010", // C
   "110010100", // D
   "110010010", // E
   "110001010", // F
   "101101000", // G
   "101100100", // H
   "101100010", // I
   "100110100", // J
   "100011010", // K
   "101011000", // L
   "101001100", // M
   "101000110", // N
   "100101100", // O
   "100010110", // P
   "110110100", // Q
   "110110010", // R
   "110101100", // S
   "110100110", // T
   "110010110", // U
   "110011010", // V
   "101101100", // W
   "101100110", // X
   "100110110", // Y
   "100111010", // Z
   "100101110", // -
   "111010100", // .
   "111010010", // space
   "111001010", // $
   "101101110", // /
   "101110110", // +
   "110101110", // %
   "100100110", // ($)
   "111011010", // (%)
   "111010110", // (/)
   "100110010", // (+)
   "101011110", // *
]

///|
/// 返回字符在 Code 93 内部字符集中的下标。
fn code93_value(c : Byte) -> Int? {
  let cs = @utf8.encode(code93_charset)
  for i = 0; i < cs.length(); i = i + 1 {
    if cs[i] == c {
      return Some(i)
    }
  }
  None
}

///|
/// 判断字节是否属于 Code 93 基本字符集。
fn code93_basic_ok(c : Byte) -> Bool {
  let cs = @utf8.encode(code93_basic_charset)
  for i = 0; i < cs.length(); i = i + 1 {
    if cs[i] == c {
      return true
    }
  }
  false
}

///|
/// 追加一个 ASCII 码对应的字节。
fn append_ascii(out : Buffer, code : Int) -> Unit {
  out.write_byte(code.to_byte())
}

///|
/// 按 Full-ASCII 规则将一个字节转换为内部字符序列（1-2 字节），
/// 写入 `out`；不可编码时返回 false。
fn code93_extend_char(c : Byte, out : Buffer) -> Bool {
  let n = c.to_int()
  if n == 0 {
    // NUL -> (%)U
    out.write_string_utf8("bU")
    return true
  }
  if n <= 26 {
    // SOH-SUB -> ($)A-($)Z
    out.write_byte(b'a')
    append_ascii(out, 65 + (n - 1))
    return true
  }
  if n <= 31 {
    // ESC-US -> (%)A-(%)E
    out.write_byte(b'b')
    append_ascii(out, 65 + (n - 27))
    return true
  }
  if c == b' ' || c == b'$' || c == b'%' || c == b'+' {
    out.write_byte(c)
    return true
  }
  if n <= 44 {
    // !"#&'()*, -> (/)A-(/)L
    out.write_byte(b'c')
    append_ascii(out, 65 + (n - 33))
    return true
  }
  if n <= 57 {
    // - . / 0-9 直接编码
    out.write_byte(c)
    return true
  }
  if c == b':' {
    out.write_string_utf8("cZ")
    return true
  }
  if n <= 63 {
    // ;<=>? -> (%)F-(%)J
    out.write_byte(b'b')
    append_ascii(out, 70 + (n - 59))
    return true
  }
  if c == b'@' {
    out.write_string_utf8("bV")
    return true
  }
  if n <= 90 {
    // A-Z 直接编码
    out.write_byte(c)
    return true
  }
  if n <= 95 {
    // [\]^_ -> (%)K-(%)O
    out.write_byte(b'b')
    append_ascii(out, 75 + (n - 91))
    return true
  }
  if c == b'`' {
    out.write_string_utf8("bW")
    return true
  }
  if n <= 122 {
    // a-z -> (+)A-(+)Z
    out.write_byte(b'd')
    append_ascii(out, 65 + (n - 97))
    return true
  }
  if n <= 127 {
    // {|}~DEL -> (%)P-(%)T
    out.write_byte(b'b')
    append_ascii(out, 80 + (n - 123))
    return true
  }
  false
}

///|
/// 将输入转换为 Code 93 内部字符序列（Buffer of bytes）。
fn code93_to_internal(
  data : String,
  full_ascii : Bool,
) -> Result[Bytes, String] {
  let b = @utf8.encode(data)
  if b.length() == 0 {
    return Err("Code 93 data must not be empty")
  }
  let out = Buffer()
  if full_ascii {
    for i = 0; i < b.length(); i = i + 1 {
      if !code93_extend_char(b[i], out) {
        return Err("Code 93 data contains a non-encodable character")
      }
    }
  } else {
    for i = 0; i < b.length(); i = i + 1 {
      if !code93_basic_ok(b[i]) {
        return Err("Code 93 basic mode rejects this character")
      }
      out.write_byte(b[i])
    }
  }
  Ok(out.to_bytes())
}

///|
/// 将内部字符序列转为值数组。
fn code93_values(chars : Bytes) -> Result[Array[Int], String] {
  let out : Array[Int] = []
  for i = 0; i < chars.length(); i = i + 1 {
    match code93_value(chars[i]) {
      None => return Err("Code 93 data contains a non-encodable character")
      Some(v) => out.push(v)
    }
  }
  Ok(out)
}

///|
/// mod-47 校验和：最右侧权重 1，向左递增，超过 `max_weight` 后重置为 1。
fn code93_checksum(values : Array[Int], max_weight : Int) -> Int {
  let mut total = 0
  let mut weight = 1
  let mut i = values.length() - 1
  while i >= 0 {
    total = total + values[i] * weight
    weight = weight + 1
    if weight > max_weight {
      weight = 1
    }
    i = i - 1
  }
  total % 47
}

///|
/// 计算 Code 93 的 C 与 K 两个 mod-47 校验值。
///
/// 权重从最右侧字符为 1 向左递增；C 的最大权重为 20，K 的最大权重为 15
/// 且计算时包含 C。
pub fn code93_checksums(
  data : String,
  full_ascii? : Bool = true,
) -> Result[(Int, Int), String] {
  match code93_to_internal(data, full_ascii) {
    Err(msg) => Err(msg)
    Ok(bytes) =>
      match code93_values(bytes) {
        Err(msg) => Err(msg)
        Ok(vs) => {
          let c = code93_checksum(vs, 20)
          let with_c : Array[Int] = []
          for v in vs {
            with_c.push(v)
          }
          with_c.push(c)
          let k = code93_checksum(with_c, 15)
          Ok((c, k))
        }
      }
  }
}

///|
/// 编码 Code 93。
///
/// `full_ascii` 为 true（默认）时支持全部 128 个 ASCII 字符（小写、标点、
/// 控制字符经移位符扩展）；为 false 时仅支持 43 个基本字符。
/// 输出结构：起始 `*` + 数据 + C + K + 终止 `*` + 终止条。
pub fn encode_code93(
  data : String,
  full_ascii? : Bool = true,
) -> Result[Barcode, EncodeError] {
  match code93_to_internal(data, full_ascii) {
    Err(msg) => Err(InvalidData(msg))
    Ok(bytes) =>
      match code93_values(bytes) {
        Err(msg) => Err(InvalidData(msg))
        Ok(vs) => {
          let c = code93_checksum(vs, 20)
          let with_c : Array[Int] = []
          for v in vs {
            with_c.push(v)
          }
          with_c.push(c)
          let k = code93_checksum(with_c, 15)
          let modules : Array[Bool] = []
          append_code93_pattern(modules, code93_patterns[47])
          for v in vs {
            append_code93_pattern(modules, code93_patterns[v])
          }
          append_code93_pattern(modules, code93_patterns[c])
          append_code93_pattern(modules, code93_patterns[k])
          append_code93_pattern(modules, code93_patterns[47])
          modules.push(true) // 终止条
          Ok({ symbology: Code93, data, modules })
        }
      }
  }
}

///|
/// 追加一个 Code 93 字符的 9 模块模式。
fn append_code93_pattern(modules : Array[Bool], pattern : String) -> Unit {
  let p = @utf8.encode(pattern)
  for i = 0; i < p.length(); i = i + 1 {
    modules.push(p[i] == b'1')
  }
}

///|
/// 校验 Code 93 数据是否可编码。
pub fn validate_code93(
  data : String,
  full_ascii? : Bool = true,
) -> Result[Unit, EncodeError] {
  match encode_code93(data, full_ascii~) {
    Err(e) => Err(e)
    Ok(_) => Ok(())
  }
}
