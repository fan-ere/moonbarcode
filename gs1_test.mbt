///|
test "parse and format common GS1 elements" {
  let source = "(01)09506000134352(17)270101(10)LOT42(21)SERIAL9"
  let elements = @moonbarcode.parse_gs1(source).unwrap()
  assert_eq(elements.length(), 4)
  assert_eq(elements[0].ai, "01")
  assert_eq(elements[0].title, "GTIN")
  assert_true(elements[0].fixed_length)
  assert_eq(elements[2].data, "LOT42")
  assert_false(elements[2].fixed_length)
  assert_eq(@moonbarcode.format_gs1(elements), source)
}

///|
test "GS1-128 payload inserts FNC1 after variable fields" {
  let elements = @moonbarcode.parse_gs1("(10)LOT42(17)270101(21)SERIAL9").unwrap()
  assert_eq(
    @moonbarcode.gs1_128_payload(elements),
    Ok("10LOT42\u{1d}1727010121SERIAL9"),
  )
}

///|
test "GS1 fixed field does not need FNC1" {
  let elements = @moonbarcode.parse_gs1("(01)09506000134352(17)270101").unwrap()
  assert_eq(
    @moonbarcode.gs1_128_payload(elements),
    Ok("010950600013435217270101"),
  )
}

///|
test "GS1 validates lengths numeric fields and checksums" {
  assert_true(@moonbarcode.parse_gs1("(01)123") is Err(_))
  assert_true(@moonbarcode.parse_gs1("(17)ABCDEF") is Err(_))
  assert_true(@moonbarcode.parse_gs1("(01)09506000134353") is Err(_))
  assert_true(@moonbarcode.parse_gs1("(999)abc") is Err(_))
  assert_true(@moonbarcode.parse_gs1("01)09506000134352") is Err(_))
  assert_true(@moonbarcode.parse_gs1("(10LOT") is Err(_))
  assert_true(@moonbarcode.parse_gs1("") is Err(_))
}

///|
test "GS1 supports measurement and amount AI families" {
  let elements = @moonbarcode.parse_gs1("(3102)001250(3902)1299").unwrap()
  assert_eq(elements.length(), 2)
  assert_eq(elements[0].title, "MEASUREMENT")
  assert_eq(elements[1].title, "AMOUNT")
  assert_true(@moonbarcode.parse_gs1("(3102)1250") is Err(_))
}

///|
test "GS1 date validation accepts unspecified day" {
  assert_true(@moonbarcode.validate_gs1_date("270101"))
  assert_true(@moonbarcode.validate_gs1_date("271200"))
  assert_false(@moonbarcode.validate_gs1_date("270000"))
  assert_false(@moonbarcode.validate_gs1_date("271332"))
  assert_false(@moonbarcode.validate_gs1_date("27AA01"))
}

///|
test "GS1 accepts maximum variable field lengths" {
  let lot = "ABCDEFGHIJKLMNOPQRST"
  let serial = "12345678901234567890"
  let source = "(10)" + lot + "(21)" + serial
  let elements = @moonbarcode.parse_gs1(source).unwrap()
  assert_eq(elements[0].data.length(), 20)
  assert_eq(elements[1].data.length(), 20)
  assert_true(@moonbarcode.parse_gs1("(10)ABCDEFGHIJKLMNOPQRSTU") is Err(_))
}

///|
test "GS1 validates SSCC and location identifiers" {
  let sscc = @moonbarcode.complete_sscc("3", "0614141", "123456789").unwrap()
  let gln = @moonbarcode.complete_gln("950110153000").unwrap()
  let source = "(00)" + sscc + "(410)" + gln
  let elements = @moonbarcode.parse_gs1(source).unwrap()
  assert_eq(elements.length(), 2)
  assert_eq(elements[0].title, "SSCC")
  assert_eq(elements[1].title, "SHIP TO GLN")
}
