///|
/// ITF / Interleaved 2 of 5 digit patterns. Each pattern has five elements:
/// `n` means a narrow bar/space and `w` means a wide bar/space.
let itf_digit_patterns : Array[String] = [
  "nnwwn", "wnnnw", "nwnnw", "wwnnn", "nnwnw", "wnwnn", "nwwnn", "nnnww", "wnnwn",
  "nwnwn",
]

///|
fn append_itf_module(modules : Array[Bool], dark : Bool, wide : Bool) -> Unit {
  let width = if wide { 3 } else { 1 }
  for i = 0; i < width; i = i + 1 {
    modules.push(dark)
  }
}

///|
fn append_itf_pattern_pair(
  modules : Array[Bool],
  left : Int,
  right : Int,
) -> Unit {
  let bars = @utf8.encode(itf_digit_patterns[left])
  let spaces = @utf8.encode(itf_digit_patterns[right])
  for i = 0; i < 5; i = i + 1 {
    append_itf_module(modules, true, bars[i] == b'w')
    append_itf_module(modules, false, spaces[i] == b'w')
  }
}

///|
/// 编码 ITF-14。
///
/// 输入为 13 位（自动追加 GTIN-14 校验位）或 14 位（校验校验位）。
/// 输出包含标准 ITF 起始/终止模式的模块序列。
pub fn encode_itf14(data : String) -> Result[Barcode, EncodeError] {
  if !only_digits_and_separators(data) {
    return Err(
      InvalidData("ITF-14 data must contain only digits and separators"),
    )
  }
  let d = strip_separators(data)
  if d.length() == 13 {
    match mod10_check(d, 3, 1) {
      Err(msg) => return Err(InvalidData(msg))
      Ok(check) => return encode_itf14_fixed(d + check.to_string())
    }
  }
  if d.length() != 14 {
    return Err(
      InvalidData(
        "ITF-14 requires 13 digits (check digit is appended) or 14 digits",
      ),
    )
  }
  if !mod10_verify(d, 3, 1) {
    return Err(InvalidData("ITF-14 check digit mismatch"))
  }
  encode_itf14_fixed(d)
}

///|
fn encode_itf14_fixed(digits : String) -> Result[Barcode, EncodeError] {
  if digits.length() != 14 || !is_all_digits(digits) {
    return Err(InvalidData("ITF-14 requires 14 decimal digits"))
  }
  let b = @utf8.encode(digits)
  let modules : Array[Bool] = []
  // Start: narrow bar, narrow space, narrow bar, narrow space.
  append_itf_module(modules, true, false)
  append_itf_module(modules, false, false)
  append_itf_module(modules, true, false)
  append_itf_module(modules, false, false)
  for i = 0; i < 14; i = i + 2 {
    let left = (b[i] - b'0').to_int()
    let right = (b[i + 1] - b'0').to_int()
    append_itf_pattern_pair(modules, left, right)
  }
  // Stop: wide bar, narrow space, narrow bar.
  append_itf_module(modules, true, true)
  append_itf_module(modules, false, false)
  append_itf_module(modules, true, false)
  Ok({ symbology: ITF14, data: digits, modules })
}
