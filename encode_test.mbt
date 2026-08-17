///|
test "dispatcher routes symbologies" {
  match @moonbarcode.encode(@moonbarcode.EAN13, "400638133393") {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.EAN8, "9638507") {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.UPCA, "03600029145") {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
}

///|
test "ITF-14 appends and validates GTIN check digit" {
  match @moonbarcode.encode(@moonbarcode.ITF14, "1234567890123") {
    Ok(b) => {
      assert_eq(b.data, "12345678901231")
      assert_eq(b.module_count(), 135)
    }
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.ITF14, "12345678901231") {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.ITF14, "12345678901230") {
    Err(@moonbarcode.InvalidData(_)) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "validate and is_valid" {
  match @moonbarcode.validate(@moonbarcode.EAN13, "4006381333931") {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
  assert_eq(@moonbarcode.is_valid(@moonbarcode.EAN13, "4006381333931"), true)
  assert_eq(@moonbarcode.is_valid(@moonbarcode.EAN13, "4006381333930"), false)
  // validate 要求完整形式（含校验位）。
  assert_eq(@moonbarcode.is_valid(@moonbarcode.EAN13, "400638133393"), false)
}

///|
test "checksum returns check digit for payload" {
  match @moonbarcode.checksum(@moonbarcode.EAN13, "400638133393") {
    Ok(c) => assert_eq(c, 1)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.checksum(@moonbarcode.EAN8, "9638507") {
    Ok(c) => assert_eq(c, 4)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.checksum(@moonbarcode.UPCA, "03600029145") {
    Ok(c) => assert_eq(c, 2)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.checksum(@moonbarcode.ITF14, "1234567890123") {
    Ok(c) => assert_eq(c, 1)
    Err(_) => assert_true(false)
  }
}
