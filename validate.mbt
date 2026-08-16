///|
/// 严格校验条码数据是否合法（格式 + 校验位）。
///
/// 与 `encode` 不同，`validate` 要求输入是包含校验位的完整形式：
/// EAN-13 13 位、EAN-8 8 位、UPC-A 12 位、ITF-14 14 位。
pub fn validate(
  symbology : Symbology,
  data : String,
) -> Result[Unit, EncodeError] {
  let d = strip_separators(data)
  match symbology {
    EAN13 =>
      if d.length() != 13 {
        Err(InvalidData("EAN-13 validation requires 13 digits"))
      } else if !mod10_verify(d, 1, 3) {
        Err(InvalidData("EAN-13 check digit mismatch"))
      } else {
        Ok(())
      }
    EAN8 =>
      if d.length() != 8 {
        Err(InvalidData("EAN-8 validation requires 8 digits"))
      } else if !mod10_verify(d, 3, 1) {
        Err(InvalidData("EAN-8 check digit mismatch"))
      } else {
        Ok(())
      }
    UPCA =>
      if d.length() != 12 {
        Err(InvalidData("UPC-A validation requires 12 digits"))
      } else if !mod10_verify(d, 3, 1) {
        Err(InvalidData("UPC-A check digit mismatch"))
      } else {
        Ok(())
      }
    ITF14 =>
      if d.length() != 14 {
        Err(InvalidData("ITF-14 validation requires 14 digits"))
      } else if !mod10_verify(d, 3, 1) {
        Err(InvalidData("ITF-14 check digit mismatch"))
      } else {
        Ok(())
      }
    Code39 => validate_code39(data)
    Code93 => Err(Unsupported("Code 93 is planned but not implemented yet"))
    Code128 => Err(Unsupported("Code 128 is planned but not implemented yet"))
  }
}

///|
/// 便捷的布尔校验入口。
pub fn is_valid(symbology : Symbology, data : String) -> Bool {
  match validate(symbology, data) {
    Ok(_) => true
    Err(_) => false
  }
}
