///|
test "strip_separators removes hyphens and spaces" {
  assert_eq(@moonbarcode.strip_separators("978-0-306-40615-7"), "9780306406157")
  assert_eq(@moonbarcode.strip_separators("0 306 40615 2"), "0306406152")
  // 只保留数字与字母 X。
  assert_eq(@moonbarcode.strip_separators("ABC-123"), "123")
}

///|
test "is_all_digits" {
  assert_eq(@moonbarcode.is_all_digits("1234567890"), true)
  assert_eq(@moonbarcode.is_all_digits("123a"), false)
  assert_eq(@moonbarcode.is_all_digits(""), false)
}

///|
test "ean13 mod10 check digit from wikipedia example" {
  match @moonbarcode.mod10_check("400638133393", 1, 3) {
    Ok(c) => assert_eq(c, 1)
    Err(_) => assert_true(false)
  }
}

///|
test "ean13 mod10 verify" {
  assert_eq(@moonbarcode.mod10_verify("4006381333931", 1, 3), true)
  assert_eq(@moonbarcode.mod10_verify("4006381333930", 1, 3), false)
}

///|
test "ean8 mod10 check digit from wikipedia example" {
  match @moonbarcode.mod10_check("7351353", 3, 1) {
    Ok(c) => assert_eq(c, 7)
    Err(_) => assert_true(false)
  }
}

///|
test "upca check digit" {
  // UPC-A 03600029145 -> check digit 2 (a common retail example).
  match @moonbarcode.mod10_check("03600029145", 3, 1) {
    Ok(c) => assert_eq(c, 2)
    Err(_) => assert_true(false)
  }
}

///|
test "mod10 rejects non digit payload" {
  match @moonbarcode.mod10_check("12a4", 1, 3) {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}
