///|
/// 按符号体系编码条码数据。
///
/// 对 EAN-13 / EAN-8 / UPC-A，输入可以是不含校验位的负载（自动追加），
/// 也可以是含校验位的完整数字串（校验是否匹配）。
pub fn encode(
  symbology : Symbology,
  data : String,
) -> Result[Barcode, EncodeError] {
  match symbology {
    EAN13 => encode_ean13(data)
    EAN8 => encode_ean8(data)
    UPCA => encode_upca(data)
    Code39 => encode_code39(data)
    Code93 => encode_code93(data)
    Code128 => encode_code128(data)
    ITF14 => encode_itf14(data)
  }
}

///|
/// 计算给定负载的校验位（不含校验位的输入）。
///
/// - EAN-13：12 位负载，校验位权重奇 1 偶 3
/// - EAN-8：7 位负载，校验位权重奇 3 偶 1
/// - UPC-A：11 位负载，校验位权重奇 3 偶 1
/// - ITF-14：13 位负载，校验位权重奇 3 偶 1
pub fn checksum(
  symbology : Symbology,
  data : String,
) -> Result[Int, EncodeError] {
  let d = strip_separators(data)
  match symbology {
    EAN13 =>
      if d.length() != 12 {
        Err(InvalidData("EAN-13 checksum requires 12 payload digits"))
      } else {
        match mod10_check(d, 1, 3) {
          Err(msg) => Err(InvalidData(msg))
          Ok(c) => Ok(c)
        }
      }
    EAN8 =>
      if d.length() != 7 {
        Err(InvalidData("EAN-8 checksum requires 7 payload digits"))
      } else {
        match mod10_check(d, 3, 1) {
          Err(msg) => Err(InvalidData(msg))
          Ok(c) => Ok(c)
        }
      }
    UPCA =>
      if d.length() != 11 {
        Err(InvalidData("UPC-A checksum requires 11 payload digits"))
      } else {
        match mod10_check(d, 3, 1) {
          Err(msg) => Err(InvalidData(msg))
          Ok(c) => Ok(c)
        }
      }
    ITF14 =>
      if d.length() != 13 {
        Err(InvalidData("ITF-14 checksum requires 13 payload digits"))
      } else {
        match mod10_check(d, 3, 1) {
          Err(msg) => Err(InvalidData(msg))
          Ok(c) => Ok(c)
        }
      }
    Code39 =>
      match code39_checksum(d) {
        Err(msg) => Err(InvalidData(msg))
        Ok(c) => Ok(c)
      }
    Code93 =>
      Err(
        InvalidData(
          "Code 93 has two check characters; use code93_checksums instead",
        ),
      )
    Code128 =>
      match code128_checksum(d) {
        Err(msg) => Err(InvalidData(msg))
        Ok(c) => Ok(c)
      }
  }
}
