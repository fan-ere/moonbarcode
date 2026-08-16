///|
/// 判断字符串是否只包含十进制数字以及常见分隔符（空格、连字符、制表符）。
fn only_digits_and_separators(s : String) -> Bool {
  let b = @utf8.encode(s)
  for i = 0; i < b.length(); i = i + 1 {
    let c = b[i]
    if !((c >= b'0' && c <= b'9') || c == b' ' || c == b'-' || c == b'\t') {
      return false
    }
  }
  true
}

///|
/// 去掉输入中的空白与常见分隔符（`-`、空格等），只保留数字和字母 X。
pub fn strip_separators(s : String) -> String {
  let b = @utf8.encode(s)
  let out = Buffer()
  for i = 0; i < b.length(); i = i + 1 {
    let c = b[i]
    if (c >= b'0' && c <= b'9') || c == b'X' || c == b'x' {
      out.write_byte(c)
    }
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// 判断字符串是否只包含十进制数字。
pub fn is_all_digits(s : String) -> Bool {
  let b = @utf8.encode(s)
  if b.length() == 0 {
    return false
  }
  for i = 0; i < b.length(); i = i + 1 {
    let c = b[i]
    if c < b'0' || c > b'9' {
      return false
    }
  }
  true
}

///|
/// 计算 mod-10 校验位。
///
/// 对从左到右的第奇数位乘以 `odd_weight`、偶数位乘以 `even_weight` 求和，
/// 校验位 = `(10 - sum % 10) % 10`。适用于 EAN-13 / EAN-8 / UPC-A / GTIN-14
/// 等以 10 为模的校验族（权重按各符号体系的规范传入）。
pub fn mod10_check(
  digits : String,
  odd_weight : Int,
  even_weight : Int,
) -> Result[Int, String] {
  if !only_digits_and_separators(digits) {
    return Err("payload must contain only decimal digits and separators")
  }
  let d = strip_separators(digits)
  if d.length() == 0 {
    return Err("payload must not be empty")
  }
  if !is_all_digits(d) {
    return Err("payload must contain only decimal digits")
  }
  let b = @utf8.encode(d)
  let mut sum = 0
  for i = 0; i < b.length(); i = i + 1 {
    let v = (b[i] - b'0').to_int()
    let weight = if (i + 1) % 2 == 1 { odd_weight } else { even_weight }
    sum = sum + v * weight
  }
  Ok((10 - sum % 10) % 10)
}

///|
/// 验证包含校验位的完整数字串（mod-10 校验族）。
pub fn mod10_verify(
  digits : String,
  odd_weight : Int,
  even_weight : Int,
) -> Bool {
  let d = strip_separators(digits)
  if d.length() < 2 || !is_all_digits(d) {
    return false
  }
  let b = @utf8.encode(d)
  let mut sum = 0
  for i = 0; i < b.length(); i = i + 1 {
    let v = (b[i] - b'0').to_int()
    let weight = if (i + 1) % 2 == 1 { odd_weight } else { even_weight }
    sum = sum + v * weight
  }
  sum % 10 == 0
}
