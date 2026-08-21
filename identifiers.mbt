///|
/// Supported GS1 identification-key forms.
pub(all) enum GtinKind {
  GTIN8
  GTIN12
  GTIN13
  GTIN14
} derive(Eq, Debug)

///|
/// Parsed and normalized GTIN information.
pub struct GtinInfo {
  kind : GtinKind
  value : String
  canonical : String
  payload : String
  check_digit : Int
} derive(Eq, Debug)

///|
/// A YYMMDD date used by GS1 date Application Identifiers.
pub struct Gs1Date {
  year : Int
  month : Int
  day : Int
} derive(Eq, Debug)

///|
fn gtin_kind_for_length(length : Int) -> GtinKind? {
  match length {
    8 => Some(GTIN8)
    12 => Some(GTIN12)
    13 => Some(GTIN13)
    14 => Some(GTIN14)
    _ => None
  }
}

///|
fn gtin_weights(length : Int) -> (Int, Int) {
  // All complete GTIN forms use alternating 3/1 weights from the right.
  // For even total lengths the leftmost payload digit therefore has weight 3.
  if length % 2 == 0 {
    (3, 1)
  } else {
    (1, 3)
  }
}

///|
fn left_pad_zero(value : String, length : Int) -> String {
  let out = Buffer()
  for i = value.length(); i < length; i = i + 1 {
    out.write_byte(b'0')
  }
  out.write_string_utf8(value)
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// Inspect a complete GTIN-8, GTIN-12 (UPC-A), GTIN-13 or GTIN-14.
pub fn inspect_gtin(value : String) -> Result[GtinInfo, String] {
  if !only_digits_and_separators(value) {
    return Err("GTIN must contain only digits and separators")
  }
  let digits = strip_separators(value)
  let kind = match gtin_kind_for_length(digits.length()) {
    Some(result) => result
    None => return Err("GTIN requires 8, 12, 13 or 14 digits")
  }
  let (odd, even) = gtin_weights(digits.length())
  if !mod10_verify(digits, odd, even) {
    return Err("GTIN check digit mismatch")
  }
  let bytes = @utf8.encode(digits)
  let check_digit = (bytes[bytes.length() - 1] - b'0').to_int()
  Ok({
    kind,
    value: digits,
    canonical: left_pad_zero(digits, 14),
    payload: digits.sub(start=0, end=digits.length() - 1).to_owned(),
    check_digit,
  })
}

///|
/// Normalize any valid GTIN form to the canonical 14-digit database form.
pub fn normalize_gtin14(value : String) -> Result[String, String] {
  match inspect_gtin(value) {
    Ok(info) => Ok(info.canonical)
    Err(message) => Err(message)
  }
}

///|
/// Build a complete GTIN from a payload of 7, 11, 12 or 13 digits.
pub fn complete_gtin(payload : String) -> Result[String, String] {
  if !is_all_digits(payload) {
    return Err("GTIN payload must contain only digits")
  }
  let total_length = payload.length() + 1
  if gtin_kind_for_length(total_length) is None {
    return Err("GTIN payload requires 7, 11, 12 or 13 digits")
  }
  let (odd, even) = gtin_weights(total_length)
  match mod10_check(payload, odd, even) {
    Ok(check) => Ok(payload + check.to_string())
    Err(message) => Err(message)
  }
}

///|
/// Return the packaging indicator digit of a valid GTIN-14.
pub fn gtin14_indicator(value : String) -> Result[Int, String] {
  match inspect_gtin(value) {
    Ok(info) =>
      if info.kind == GTIN14 {
        Ok((@utf8.encode(info.value)[0] - b'0').to_int())
      } else {
        Err("packaging indicator is only defined for GTIN-14")
      }
    Err(message) => Err(message)
  }
}

///|
/// Construct an 18-digit Serial Shipping Container Code. The extension digit,
/// company prefix and serial reference must together contain 17 digits.
pub fn complete_sscc(
  extension : String,
  company_prefix : String,
  serial_reference : String,
) -> Result[String, String] {
  let payload = extension + company_prefix + serial_reference
  if extension.length() != 1 || !is_all_digits(payload) {
    return Err(
      "SSCC components must be numeric and extension must be one digit",
    )
  }
  if payload.length() != 17 {
    return Err("SSCC payload must contain exactly 17 digits")
  }
  match mod10_check(payload, 3, 1) {
    Ok(check) => Ok(payload + check.to_string())
    Err(message) => Err(message)
  }
}

///|
pub fn validate_sscc(value : String) -> Bool {
  let digits = strip_separators(value)
  digits.length() == 18 && is_all_digits(digits) && mod10_verify(digits, 3, 1)
}

///|
/// Construct a 13-digit Global Location Number from its 12-digit payload.
pub fn complete_gln(payload : String) -> Result[String, String] {
  if payload.length() != 12 || !is_all_digits(payload) {
    return Err("GLN payload must contain exactly 12 digits")
  }
  match mod10_check(payload, 1, 3) {
    Ok(check) => Ok(payload + check.to_string())
    Err(message) => Err(message)
  }
}

///|
pub fn validate_gln(value : String) -> Bool {
  let digits = strip_separators(value)
  digits.length() == 13 && is_all_digits(digits) && mod10_verify(digits, 1, 3)
}

///|
fn two_digits(bytes : Bytes, offset : Int) -> Int {
  (bytes[offset] - b'0').to_int() * 10 + (bytes[offset + 1] - b'0').to_int()
}

///|
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if year % 4 == 0 { 29 } else { 28 }
    _ => 0
  }
}

///|
/// Parse a GS1 YYMMDD date. Day 00 is preserved as an unspecified day.
pub fn parse_gs1_date(value : String) -> Result[Gs1Date, String] {
  if value.length() != 6 || !is_all_digits(value) {
    return Err("GS1 date requires six digits in YYMMDD form")
  }
  let bytes = @utf8.encode(value)
  let year = two_digits(bytes, 0)
  let month = two_digits(bytes, 2)
  let day = two_digits(bytes, 4)
  if month < 1 || month > 12 {
    return Err("GS1 date month is out of range")
  }
  if day < 0 || day > days_in_month(year, month) {
    return Err("GS1 date day is out of range")
  }
  Ok({ year, month, day })
}

///|
fn append_two_digits(out : Buffer, value : Int) -> Unit {
  out.write_byte(b'0' + (value / 10).to_byte())
  out.write_byte(b'0' + (value % 10).to_byte())
}

///|
/// Format a GS1 date after validating all fields.
pub fn format_gs1_date(date : Gs1Date) -> Result[String, String] {
  if date.year < 0 || date.year > 99 {
    return Err("GS1 year must be between 00 and 99")
  }
  if date.month < 1 || date.month > 12 {
    return Err("GS1 month must be between 01 and 12")
  }
  if date.day < 0 || date.day > days_in_month(date.year, date.month) {
    return Err("GS1 day is out of range")
  }
  let out = Buffer()
  append_two_digits(out, date.year)
  append_two_digits(out, date.month)
  append_two_digits(out, date.day)
  Ok(@utf8.decode_lossy(out.to_bytes()))
}
