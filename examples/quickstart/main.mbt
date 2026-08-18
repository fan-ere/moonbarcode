///|
fn main {
  let ean = match @lib.encode(@lib.EAN13, "6901234567892") {
    Ok(b) => b
    Err(e) => {
      println("EAN-13 encode failed: \{@lib.error_message(e)}")
      return
    }
  }
  println("EAN-13 ASCII preview:")
  println(@lib.render_ascii(ean, @lib.BarcodeOptions::new(show_text=false)))
  println("")

  let itf = match @lib.encode(@lib.ITF14, "1234567890123") {
    Ok(b) => b
    Err(e) => {
      println("ITF-14 encode failed: \{@lib.error_message(e)}")
      return
    }
  }
  println("ITF-14 checksum demo:")
  println("  payload -> \{itf.data}")
  println("  bars    -> \{itf.bar_count()}")
}
