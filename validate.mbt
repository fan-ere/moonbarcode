///|
/// 校验条码数据是否合法（格式 + 校验位）。
pub fn validate(
  symbology : Symbology,
  data : String,
) -> Result[Unit, EncodeError] {
  match encode(symbology, data) {
    Err(e) => Err(e)
    Ok(_) => Ok(())
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
