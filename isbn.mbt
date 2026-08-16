///|
/// 校验 ISBN-10（允许连字符与空格，校验位可为 X）。
///
/// 校验规则：第 i 位（1-based）乘以权重 `11 - i` 求和，和须能被 11 整除；
/// 校验位 X 表示 10。
pub fn isbn10_valid(s : String) -> Bool {
  let d = strip_separators(s)
  if d.length() != 10 {
    return false
  }
  let b = @utf8.encode(d)
  let mut sum = 0
  for i = 0; i < 10; i = i + 1 {
    let c = b[i]
    let v = if i == 9 && (c == b'X' || c == b'x') {
      10
    } else if c >= b'0' && c <= b'9' {
      (c - b'0').to_int()
    } else {
      return false
    }
    sum = sum + v * (10 - i)
  }
  sum % 11 == 0
}

///|
/// 校验 ISBN-13（允许连字符与空格），规则同 EAN-13。
pub fn isbn13_valid(s : String) -> Bool {
  let d = strip_separators(s)
  if d.length() != 13 {
    return false
  }
  mod10_verify(d, 1, 3)
}

///|
/// 校验 ISSN（允许连字符与空格，校验位可为 X）。
///
/// 校验规则：前 7 位乘以权重 8..2 求和，校验位 = `(11 - sum % 11) % 11`，
/// 10 记作 X，11 记作 0。
pub fn issn_valid(s : String) -> Bool {
  let d = strip_separators(s)
  if d.length() != 8 {
    return false
  }
  let b = @utf8.encode(d)
  let mut sum = 0
  for i = 0; i < 7; i = i + 1 {
    let c = b[i]
    if c < b'0' || c > b'9' {
      return false
    }
    sum = sum + (c - b'0').to_int() * (8 - i)
  }
  let check = (11 - sum % 11) % 11
  let c = b[7]
  if c == b'X' || c == b'x' {
    check == 10
  } else if c >= b'0' && c <= b'9' {
    (c - b'0').to_int() == check
  } else {
    false
  }
}

///|
/// 计算 GTIN-14（14 位，ITF-14 使用的数据结构）的校验位。
/// 输入为 13 位负载，权重从左起奇位为 3、偶位为 1。
pub fn gtin14_checksum(data : String) -> Result[Int, String] {
  let d = strip_separators(data)
  if d.length() != 13 {
    return Err("GTIN-14 requires 13 payload digits")
  }
  mod10_check(d, 3, 1)
}

///|
/// 校验完整的 GTIN-14（含校验位）。
pub fn gtin14_valid(s : String) -> Bool {
  let d = strip_separators(s)
  if d.length() != 14 {
    return false
  }
  mod10_verify(d, 3, 1)
}
