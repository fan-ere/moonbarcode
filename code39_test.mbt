///|
test "code39 encodes single char with start and stop" {
  match @moonbarcode.encode(@moonbarcode.Code39, "A") {
    Ok(b) => {
      assert_eq(b.module_count(), 47)
      assert_eq(b.symbology, @moonbarcode.Code39)
      // 起始/终止与数据字符之间各有 1 个窄空。
      let m = b.modules
      assert_eq(m[0] && !m[1], true)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "code39 module count formula" {
  match @moonbarcode.encode(@moonbarcode.Code39, "ABC") {
    Ok(b) => assert_eq(b.module_count(), 79)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.Code39, "HELLO") {
    Ok(b) => assert_eq(b.module_count(), 111)
    Err(_) => assert_true(false)
  }
}

///|
test "code39 checksum mod43" {
  match @moonbarcode.code39_checksum("ABC") {
    Ok(33) => assert_true(true)
    _ => assert_true(false)
  }
  match @moonbarcode.code39_checksum("HELLO") {
    Ok(11) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "code39 with checksum appends check character" {
  match @moonbarcode.encode_code39("ABC", with_checksum=true) {
    Ok(b) => {
      assert_eq(b.data, "ABCX")
      assert_eq(b.module_count(), 16 * 4 + 31)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "code39 rejects unsupported characters" {
  match @moonbarcode.encode(@moonbarcode.Code39, "abc") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.Code39, "A*B") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.Code39, "") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}

///|
test "code39 validate" {
  assert_eq(@moonbarcode.is_valid(@moonbarcode.Code39, "MOONBIT-2026"), true)
  assert_eq(@moonbarcode.is_valid(@moonbarcode.Code39, "lower"), false)
}
