///|
/// Decoding failures for module-level barcode readers.
pub(all) enum DecodeError {
  InvalidModules(String)
  ChecksumMismatch(String)
} derive(Eq, Debug)

///|
pub fn decode_error_message(error : DecodeError) -> String {
  match error {
    InvalidModules(message) => "invalid modules: \{message}"
    ChecksumMismatch(message) => "checksum mismatch: \{message}"
  }
}

///|
fn module_pattern(modules : Array[Bool], start : Int, length : Int) -> String {
  let out = Buffer()
  for i = start; i < start + length; i = i + 1 {
    out.write_byte(if modules[i] { b'1' } else { b'0' })
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
fn pattern_digit(pattern : String, table : Array[String]) -> Int? {
  for i = 0; i < table.length(); i = i + 1 {
    if pattern == table[i] {
      return Some(i)
    }
  }
  None
}

///|
fn parity_digit(pattern : String) -> Int? {
  for i = 0; i < ean13_parity.length(); i = i + 1 {
    if pattern == ean13_parity[i] {
      return Some(i)
    }
  }
  None
}

///|
fn append_decimal(out : Buffer, value : Int) -> Unit {
  out.write_byte(b'0' + value.to_byte())
}

///|
/// Decode a canonical 95-module EAN-13 symbol and verify its check digit.
pub fn decode_ean13(modules : Array[Bool]) -> Result[String, DecodeError] {
  if modules.length() != 95 {
    return Err(InvalidModules("EAN-13 requires exactly 95 modules"))
  }
  if module_pattern(modules, 0, 3) != "101" ||
    module_pattern(modules, 45, 5) != "01010" ||
    module_pattern(modules, 92, 3) != "101" {
    return Err(InvalidModules("EAN-13 guard pattern is invalid"))
  }
  let parity = Buffer()
  let left_digits : Array[Int] = []
  for i = 0; i < 6; i = i + 1 {
    let pattern = module_pattern(modules, 3 + i * 7, 7)
    match pattern_digit(pattern, l_code) {
      Some(digit) => {
        parity.write_byte(b'0')
        left_digits.push(digit)
      }
      None =>
        match pattern_digit(pattern, g_code) {
          Some(digit) => {
            parity.write_byte(b'1')
            left_digits.push(digit)
          }
          None =>
            return Err(
              InvalidModules("EAN-13 left digit \{i + 1} has no valid pattern"),
            )
        }
    }
  }
  let first = match parity_digit(@utf8.decode_lossy(parity.to_bytes())) {
    Some(digit) => digit
    None => return Err(InvalidModules("EAN-13 parity pattern is invalid"))
  }
  let out = Buffer()
  append_decimal(out, first)
  for digit in left_digits {
    append_decimal(out, digit)
  }
  for i = 0; i < 6; i = i + 1 {
    let pattern = module_pattern(modules, 50 + i * 7, 7)
    match pattern_digit(pattern, r_code) {
      Some(digit) => append_decimal(out, digit)
      None =>
        return Err(
          InvalidModules("EAN-13 right digit \{i + 1} has no valid pattern"),
        )
    }
  }
  let data = @utf8.decode_lossy(out.to_bytes())
  if !mod10_verify(data, 1, 3) {
    return Err(ChecksumMismatch("EAN-13 check digit does not match"))
  }
  Ok(data)
}

///|
/// Decode a canonical 67-module EAN-8 symbol and verify its check digit.
pub fn decode_ean8(modules : Array[Bool]) -> Result[String, DecodeError] {
  if modules.length() != 67 {
    return Err(InvalidModules("EAN-8 requires exactly 67 modules"))
  }
  if module_pattern(modules, 0, 3) != "101" ||
    module_pattern(modules, 31, 5) != "01010" ||
    module_pattern(modules, 64, 3) != "101" {
    return Err(InvalidModules("EAN-8 guard pattern is invalid"))
  }
  let out = Buffer()
  for i = 0; i < 4; i = i + 1 {
    match pattern_digit(module_pattern(modules, 3 + i * 7, 7), l_code) {
      Some(digit) => append_decimal(out, digit)
      None => return Err(InvalidModules("EAN-8 left digit \{i + 1} is invalid"))
    }
  }
  for i = 0; i < 4; i = i + 1 {
    match pattern_digit(module_pattern(modules, 36 + i * 7, 7), r_code) {
      Some(digit) => append_decimal(out, digit)
      None =>
        return Err(InvalidModules("EAN-8 right digit \{i + 1} is invalid"))
    }
  }
  let data = @utf8.decode_lossy(out.to_bytes())
  if !mod10_verify(data, 3, 1) {
    return Err(ChecksumMismatch("EAN-8 check digit does not match"))
  }
  Ok(data)
}

///|
/// Decode UPC-A through its standards-compatible EAN-13 representation.
pub fn decode_upca(modules : Array[Bool]) -> Result[String, DecodeError] {
  match decode_ean13(modules) {
    Err(error) => Err(error)
    Ok(data) =>
      if data.has_prefix("0") {
        Ok(data.sub(start=1, end=data.length()).to_owned())
      } else {
        Err(InvalidModules("UPC-A EAN-13 prefix must be zero"))
      }
  }
}

///|
fn read_runs(modules : Array[Bool]) -> Array[(Bool, Int)] {
  let runs : Array[(Bool, Int)] = []
  if modules.is_empty() {
    return runs
  }
  let mut dark = modules[0]
  let mut width = 1
  for i = 1; i < modules.length(); i = i + 1 {
    if modules[i] == dark {
      width = width + 1
    } else {
      runs.push((dark, width))
      dark = modules[i]
      width = 1
    }
  }
  runs.push((dark, width))
  runs
}

///|
fn itf_pattern_digit(pattern : String) -> Int? {
  for i = 0; i < itf_digit_patterns.length(); i = i + 1 {
    if pattern == itf_digit_patterns[i] {
      return Some(i)
    }
  }
  None
}

///|
fn runs_to_itf_pattern(runs : Array[(Bool, Int)], start : Int) -> String {
  let out = Buffer()
  for i = start; i < start + 10; i = i + 2 {
    out.write_byte(if runs[i].1 == 3 { b'w' } else { b'n' })
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// Decode an ITF-14 module stream produced with the standard 3:1 wide ratio.
pub fn decode_itf14(modules : Array[Bool]) -> Result[String, DecodeError] {
  let runs = read_runs(modules)
  if runs.length() != 77 {
    return Err(InvalidModules("ITF-14 requires 77 alternating elements"))
  }
  if runs[0] != (true, 1) ||
    runs[1] != (false, 1) ||
    runs[2] != (true, 1) ||
    runs[3] != (false, 1) {
    return Err(InvalidModules("ITF-14 start pattern is invalid"))
  }
  if runs[74] != (true, 3) || runs[75] != (false, 1) || runs[76] != (true, 1) {
    return Err(InvalidModules("ITF-14 stop pattern is invalid"))
  }
  for i = 4; i < 74; i = i + 1 {
    if runs[i].1 != 1 && runs[i].1 != 3 {
      return Err(InvalidModules("ITF-14 element width must be 1 or 3"))
    }
  }
  let out = Buffer()
  for pair = 0; pair < 7; pair = pair + 1 {
    let offset = 4 + pair * 10
    let bars = runs_to_itf_pattern(runs, offset)
    let spaces = runs_to_itf_pattern(runs, offset + 1)
    match (itf_pattern_digit(bars), itf_pattern_digit(spaces)) {
      (Some(left), Some(right)) => {
        append_decimal(out, left)
        append_decimal(out, right)
      }
      _ =>
        return Err(InvalidModules("ITF-14 digit pair \{pair + 1} is invalid"))
    }
  }
  let data = @utf8.decode_lossy(out.to_bytes())
  if !mod10_verify(data, 3, 1) {
    return Err(ChecksumMismatch("ITF-14 check digit does not match"))
  }
  Ok(data)
}

///|
fn code39_pattern_from_runs(runs : Array[(Bool, Int)], start : Int) -> String {
  let out = Buffer()
  for i = start; i < start + 9; i = i + 1 {
    out.write_byte(if runs[i].1 == 3 { b'1' } else { b'0' })
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
fn code39_pattern_value(pattern : String) -> Int? {
  for i = 0; i < code39_patterns.length(); i = i + 1 {
    if pattern == code39_patterns[i] {
      return Some(i)
    }
  }
  None
}

///|
/// Decode a basic Code 39 symbol. When `verify_checksum` is true, the final
/// data character is treated as mod-43 checksum and removed from the result.
pub fn decode_code39(
  modules : Array[Bool],
  verify_checksum? : Bool = false,
) -> Result[String, DecodeError] {
  let runs = read_runs(modules)
  if runs.length() < 29 || (runs.length() - 19) % 10 != 0 {
    return Err(InvalidModules("Code 39 element count is invalid"))
  }
  if code39_pattern_from_runs(runs, 0) != code39_star ||
    code39_pattern_from_runs(runs, runs.length() - 9) != code39_star {
    return Err(InvalidModules("Code 39 start or stop pattern is invalid"))
  }
  let count = (runs.length() - 19) / 10
  let out = Buffer()
  let charset = @utf8.encode(code39_charset)
  for i = 0; i < count; i = i + 1 {
    let separator = 9 + i * 10
    if runs[separator] != (false, 1) {
      return Err(InvalidModules("Code 39 inter-character gap is invalid"))
    }
    let pattern = code39_pattern_from_runs(runs, separator + 1)
    match code39_pattern_value(pattern) {
      Some(value) => out.write_byte(charset[value])
      None =>
        return Err(InvalidModules("Code 39 character \{i + 1} is invalid"))
    }
  }
  if runs[runs.length() - 10] != (false, 1) {
    return Err(InvalidModules("Code 39 final gap is invalid"))
  }
  let data = @utf8.decode_lossy(out.to_bytes())
  if !verify_checksum {
    return Ok(data)
  }
  if data.length() < 2 {
    return Err(ChecksumMismatch("Code 39 checksum requires payload data"))
  }
  let payload = data.sub(start=0, end=data.length() - 1).to_owned()
  let check = @utf8.encode(data)[data.length() - 1]
  match code39_checksum(payload) {
    Ok(value) =>
      if charset[value] == check {
        Ok(payload)
      } else {
        Err(ChecksumMismatch("Code 39 mod-43 checksum does not match"))
      }
    Err(message) => Err(ChecksumMismatch(message))
  }
}
