///|
test "inspect and normalize all GTIN forms" {
  let cases = [
    ("96385074", @moonbarcode.GTIN8, "00000096385074"),
    ("036000291452", @moonbarcode.GTIN12, "00036000291452"),
    ("4006381333931", @moonbarcode.GTIN13, "04006381333931"),
    ("12345678901231", @moonbarcode.GTIN14, "12345678901231"),
  ]
  for item in cases {
    let (value, kind, canonical) = item
    let info = @moonbarcode.inspect_gtin(value).unwrap()
    assert_eq(info.kind, kind)
    assert_eq(info.value, value)
    assert_eq(info.canonical, canonical)
    assert_eq(
      info.check_digit,
      (@utf8.encode(value)[value.length() - 1] - b'0').to_int(),
    )
    assert_eq(@moonbarcode.normalize_gtin14(value), Ok(canonical))
  }
}

///|
test "complete GTIN payloads" {
  assert_eq(@moonbarcode.complete_gtin("9638507"), Ok("96385074"))
  assert_eq(@moonbarcode.complete_gtin("03600029145"), Ok("036000291452"))
  assert_eq(@moonbarcode.complete_gtin("400638133393"), Ok("4006381333931"))
  assert_eq(@moonbarcode.complete_gtin("1234567890123"), Ok("12345678901231"))
}

///|
test "GTIN utilities reject malformed values" {
  assert_true(@moonbarcode.inspect_gtin("123") is Err(_))
  assert_true(@moonbarcode.inspect_gtin("4006381333930") is Err(_))
  assert_true(@moonbarcode.inspect_gtin("40063813339A1") is Err(_))
  assert_true(@moonbarcode.complete_gtin("12345") is Err(_))
  assert_true(@moonbarcode.complete_gtin("123456A") is Err(_))
}

///|
test "GTIN-14 packaging indicator" {
  assert_eq(@moonbarcode.gtin14_indicator("12345678901231"), Ok(1))
  assert_true(@moonbarcode.gtin14_indicator("4006381333931") is Err(_))
}

///|
test "SSCC completion and validation" {
  let sscc = @moonbarcode.complete_sscc("3", "0614141", "123456789").unwrap()
  assert_eq(sscc.length(), 18)
  assert_true(@moonbarcode.validate_sscc(sscc))
  assert_false(@moonbarcode.validate_sscc("306141411234567890"))
  assert_true(@moonbarcode.complete_sscc("12", "0614141", "12345678") is Err(_))
  assert_true(@moonbarcode.complete_sscc("3", "0614141", "ABC") is Err(_))
}

///|
test "GLN completion and validation" {
  let gln = @moonbarcode.complete_gln("950110153000").unwrap()
  assert_eq(gln, "9501101530003")
  assert_true(@moonbarcode.validate_gln(gln))
  assert_false(@moonbarcode.validate_gln("9501101530004"))
  assert_true(@moonbarcode.complete_gln("123") is Err(_))
}

///|
test "GS1 date parse and format" {
  let date = @moonbarcode.parse_gs1_date("240229").unwrap()
  assert_eq(date.year, 24)
  assert_eq(date.month, 2)
  assert_eq(date.day, 29)
  assert_eq(@moonbarcode.format_gs1_date(date), Ok("240229"))
  let unspecified = @moonbarcode.parse_gs1_date("271200").unwrap()
  assert_eq(unspecified.day, 0)
  assert_eq(@moonbarcode.format_gs1_date(unspecified), Ok("271200"))
}

///|
test "GS1 date rejects invalid calendar values" {
  assert_true(@moonbarcode.parse_gs1_date("230229") is Err(_))
  assert_true(@moonbarcode.parse_gs1_date("241331") is Err(_))
  assert_true(@moonbarcode.parse_gs1_date("240431") is Err(_))
  assert_true(@moonbarcode.parse_gs1_date("24AA01") is Err(_))
  assert_true(@moonbarcode.parse_gs1_date("24010") is Err(_))
}

///|
test "identifier validators accept display separators" {
  assert_eq(
    @moonbarcode.normalize_gtin14("400-6381-333931"),
    Ok("04006381333931"),
  )
  let sscc = @moonbarcode.complete_sscc("3", "0614141", "123456789").unwrap()
  let displayed_sscc = sscc.sub(start=0, end=6).to_owned() +
    " " +
    sscc.sub(start=6, end=12).to_owned() +
    " " +
    sscc.sub(start=12, end=18).to_owned()
  assert_true(@moonbarcode.validate_sscc(displayed_sscc))
  assert_true(@moonbarcode.validate_gln("950-1101-530003"))
}

///|
test "complete identifiers produce inspectable check digits" {
  let payloads = ["9638507", "03600029145", "400638133393", "1234567890123"]
  for payload in payloads {
    let completed = @moonbarcode.complete_gtin(payload).unwrap()
    let info = @moonbarcode.inspect_gtin(completed).unwrap()
    assert_eq(info.payload, payload)
    assert_true(info.check_digit >= 0 && info.check_digit <= 9)
  }
}
