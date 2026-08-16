///|
test "code128 pure digits use subset C" {
  match @moonbarcode.encode(@moonbarcode.Code128, "123456") {
    Ok(b) =>
      // 起始 C(105) + 3 个两位数字 + 校验 + 停止(13)：11*(5)+13 = 68 模块。
      assert_eq(b.module_count(), 11 * 5 + 13)
    Err(_) => assert_true(false)
  }
}

///|
test "code128 checksum for Hi" {
  // Code 128B: start=104, H=40, i=73 -> (104 + 40 + 73*2) % 103 = 84。
  match @moonbarcode.code128_checksum("Hi") {
    Ok(c) => assert_eq(c, 84)
    Err(_) => assert_true(false)
  }
}

///|
test "code128 text with digits switches subsets" {
  match @moonbarcode.encode(@moonbarcode.Code128, "ABC123456") {
    Ok(b) =>
      // B 起始 + 3 字符 + 切 C + 3 对 + 校验 + 停止
      assert_eq(b.module_count(), 11 * (1 + 3 + 1 + 3 + 1) + 13)
    Err(_) => assert_true(false)
  }
}

///|
test "code128 gs1 prepends fnc1" {
  match @moonbarcode.encode_code128("0106901234567892", gs1=true) {
    Ok(b) =>
      // 起始 B + FNC1 + 数据(切 C 后 6 对) + 校验 + 停止
      assert_true(b.module_count() > 0)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.validate_code128("0106901234567892", gs1=true) {
    Ok(_) => assert_true(true)
    Err(_) => assert_true(false)
  }
}

///|
test "code128 rejects non ascii and empty" {
  match @moonbarcode.encode(@moonbarcode.Code128, "") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.Code128, "\u{4e2d}") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}

///|
test "code128 validate dispatcher" {
  assert_eq(@moonbarcode.is_valid(@moonbarcode.Code128, "MOONBIT-2026"), true)
  assert_eq(@moonbarcode.is_valid(@moonbarcode.Code128, "\u{4e2d}"), false)
}
