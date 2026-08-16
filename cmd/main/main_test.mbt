///|
test "parse_symbology maps names" {
  match parse_symbology("ean13") {
    Some(@lib.EAN13) => assert_true(true)
    _ => assert_true(false)
  }
  match parse_symbology("code128") {
    Some(@lib.Code128) => assert_true(true)
    _ => assert_true(false)
  }
  match parse_symbology("nope") {
    None => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "parse_int handles signs and junk" {
  match parse_int("42") {
    Some(42) => assert_true(true)
    _ => assert_true(false)
  }
  match parse_int("-7") {
    Some(-7) => assert_true(true)
    _ => assert_true(false)
  }
  match parse_int("abc") {
    None => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "parse_encode_args extracts options" {
  let args = [
    "moonbarcode", "encode", "--type", "ean13", "--data", "400638133393", "--format",
    "ascii", "--out", "x.txt", "--height", "60", "--module-width", "3", "--quiet-zone",
    "12", "--no-text",
  ]
  let opts = parse_encode_args(args)
  assert_eq(opts.sym, "ean13")
  assert_eq(opts.data, "400638133393")
  assert_eq(opts.format, "ascii")
  assert_eq(opts.out_path, "x.txt")
  assert_eq(opts.height, 60)
  assert_eq(opts.module_width, 3)
  assert_eq(opts.quiet_zone, 12)
  assert_eq(opts.show_text, false)
}
