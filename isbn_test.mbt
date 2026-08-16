///|
test "isbn10 valid examples" {
  assert_eq(@moonbarcode.isbn10_valid("0-306-40615-2"), true)
  assert_eq(@moonbarcode.isbn10_valid("0306406152"), true)
  assert_eq(@moonbarcode.isbn10_valid("0306406153"), false)
  assert_eq(@moonbarcode.isbn10_valid("123"), false)
}

///|
test "isbn13 valid examples" {
  assert_eq(@moonbarcode.isbn13_valid("978-0-306-40615-7"), true)
  assert_eq(@moonbarcode.isbn13_valid("9780306406157"), true)
  assert_eq(@moonbarcode.isbn13_valid("9780306406156"), false)
}

///|
test "issn valid examples" {
  assert_eq(@moonbarcode.issn_valid("0317-8471"), true)
  assert_eq(@moonbarcode.issn_valid("03178471"), true)
  assert_eq(@moonbarcode.issn_valid("0317-8472"), false)
  assert_eq(@moonbarcode.issn_valid("2049-3630"), true)
}

///|
test "gtin14 checksum and validation" {
  match @moonbarcode.gtin14_checksum("1546014120800") {
    Ok(c) => assert_eq(c, 0)
    Err(_) => assert_true(false)
  }
  assert_eq(@moonbarcode.gtin14_valid("15460141208000"), true)
  assert_eq(@moonbarcode.gtin14_valid("15460141208001"), false)
}
