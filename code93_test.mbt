///|
test "code93 module count formula" {
  // (n + 4) * 9 + 1，含 C/K 校验与终止条。
  match @moonbarcode.encode_code93("A") {
    Ok(b) => assert_eq(b.module_count(), 46)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode_code93("CODE93") {
    Ok(b) => assert_eq(b.module_count(), 91)
    Err(_) => assert_true(false)
  }
}

///|
test "code93 checksums for CODE93" {
  match @moonbarcode.code93_checksums("CODE93") {
    Ok((25, 31)) => assert_true(true)
    _ => assert_true(false)
  }
  match @moonbarcode.code93_checksums("A") {
    Ok((10, 30)) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "code93 starts and ends with stop and termination bar" {
  match @moonbarcode.encode_code93("HELLO") {
    Ok(b) => {
      let m = b.modules
      // 起始 * = 101011110
      assert_eq(m[0] && !m[1] && m[2], true)
      // 终止条在最后
      assert_eq(m[m.length() - 1], true)
      assert_eq(b.symbology, @moonbarcode.Code93)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "code93 full ascii encodes lowercase via shift chars" {
  match @moonbarcode.encode_code93("moonbit") {
    Ok(b) =>
      // moonbit -> dMdOdOdNdBdIdT (14 个内部字符) + C/K + 起止
      assert_eq(b.module_count(), (14 + 4) * 9 + 1)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.code93_checksums("moonbit") {
    Ok((22, 0)) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "code93 basic mode rejects lowercase" {
  match @moonbarcode.encode_code93("abc", full_ascii=false) {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
  match @moonbarcode.encode_code93("ABC", full_ascii=false) {
    Ok(b) => assert_eq(b.module_count(), (3 + 4) * 9 + 1)
    Err(_) => assert_true(false)
  }
}

///|
test "code93 rejects empty and non ascii" {
  match @moonbarcode.encode_code93("") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
  match @moonbarcode.encode_code93("\u{4e2d}") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}

///|
test "code93 validate dispatcher" {
  assert_eq(@moonbarcode.is_valid(@moonbarcode.Code93, "MoonBit-2026"), true)
  assert_eq(@moonbarcode.is_valid(@moonbarcode.Code93, "\u{4e2d}"), false)
}
