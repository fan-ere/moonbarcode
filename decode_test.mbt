///|
test "EAN-13 decode round trip" {
  let barcode = @moonbarcode.encode(@moonbarcode.EAN13, "4006381333931").unwrap()
  assert_eq(@moonbarcode.decode_ean13(barcode.modules), Ok("4006381333931"))
}

///|
test "EAN-13 decoder covers all parity prefixes" {
  for prefix = 0; prefix <= 9; prefix = prefix + 1 {
    let payload = prefix.to_string() + "12345678901"
    let barcode = @moonbarcode.encode(@moonbarcode.EAN13, payload).unwrap()
    assert_eq(@moonbarcode.decode_ean13(barcode.modules), Ok(barcode.data))
  }
}

///|
test "EAN-13 decode rejects guards and checksum damage" {
  let barcode = @moonbarcode.encode(@moonbarcode.EAN13, "4006381333931").unwrap()
  let bad_guard = barcode.modules.copy()
  bad_guard[0] = false
  assert_true(@moonbarcode.decode_ean13(bad_guard) is Err(_))
  let bad_digit = barcode.modules.copy()
  for i = 85; i < 92; i = i + 1 {
    bad_digit[i] = @moonbarcode.encode(@moonbarcode.EAN13, "4006381333924").unwrap().modules[i]
  }
  assert_true(@moonbarcode.decode_ean13(bad_digit) is Err(_))
}

///|
test "EAN-8 and UPC-A decode round trips" {
  let ean8 = @moonbarcode.encode(@moonbarcode.EAN8, "96385074").unwrap()
  assert_eq(@moonbarcode.decode_ean8(ean8.modules), Ok("96385074"))
  let upca = @moonbarcode.encode(@moonbarcode.UPCA, "036000291452").unwrap()
  assert_eq(@moonbarcode.decode_upca(upca.modules), Ok("036000291452"))
}

///|
test "EAN decoders reject wrong module lengths" {
  assert_true(@moonbarcode.decode_ean13([true, false, true]) is Err(_))
  assert_true(@moonbarcode.decode_ean8([]) is Err(_))
  let non_upc = @moonbarcode.encode(@moonbarcode.EAN13, "4006381333931").unwrap()
  assert_true(@moonbarcode.decode_upca(non_upc.modules) is Err(_))
}

///|
test "ITF-14 decode round trip" {
  let values = ["12345678901231", "00012345600012", "95012345678903"]
  for value in values {
    let barcode = @moonbarcode.encode(@moonbarcode.ITF14, value).unwrap()
    assert_eq(@moonbarcode.decode_itf14(barcode.modules), Ok(value))
  }
}

///|
test "ITF-14 decode rejects invalid start and width" {
  let barcode = @moonbarcode.encode(@moonbarcode.ITF14, "12345678901231").unwrap()
  let start = barcode.modules.copy()
  start[0] = false
  assert_true(@moonbarcode.decode_itf14(start) is Err(_))
  let short = barcode.modules.copy()
  let _ = short.pop()
  assert_true(@moonbarcode.decode_itf14(short) is Err(_))
}

///|
test "Code 39 decode round trip and checksum" {
  let plain = @moonbarcode.encode_code39("MOONBIT-2026").unwrap()
  assert_eq(@moonbarcode.decode_code39(plain.modules), Ok("MOONBIT-2026"))
  let checked = @moonbarcode.encode_code39("TRACK42", with_checksum=true).unwrap()
  assert_eq(
    @moonbarcode.decode_code39(checked.modules, verify_checksum=true),
    Ok("TRACK42"),
  )
}

///|
test "Code 39 decoder detects damage" {
  let barcode = @moonbarcode.encode_code39("ABC", with_checksum=true).unwrap()
  let damaged = barcode.modules.copy()
  damaged[0] = false
  assert_true(@moonbarcode.decode_code39(damaged) is Err(_))
  assert_true(
    @moonbarcode.decode_code39(
      @moonbarcode.encode_code39("ABC").unwrap().modules,
      verify_checksum=true,
    )
    is Err(_),
  )
}

///|
test "decoders compose with binary transport" {
  let original = @moonbarcode.encode(@moonbarcode.EAN13, "6901234567892").unwrap()
  let wire = @moonbarcode.modules_to_binary(original.modules)
  let restored = @moonbarcode.modules_from_binary(wire).unwrap()
  assert_eq(@moonbarcode.decode_ean13(restored), Ok("6901234567892"))
  assert_eq(@moonbarcode.hamming_distance(original.modules, restored), Some(0))
}

///|
test "quiet zones can be removed before decoding" {
  let original = @moonbarcode.encode(@moonbarcode.EAN8, "96385074").unwrap()
  let scanned = @moonbarcode.add_quiet_zone(original.modules, 12)
  assert_eq(scanned.length(), 91)
  assert_eq(
    @moonbarcode.decode_ean8(@moonbarcode.trim_quiet_zone(scanned)),
    Ok("96385074"),
  )
}

///|
test "module analysis describes generated symbols" {
  let ean = @moonbarcode.encode(@moonbarcode.EAN13, "4006381333931").unwrap()
  let ean_stats = @moonbarcode.analyze_modules(ean.modules)
  assert_eq(ean_stats.module_count, 95)
  assert_true(ean_stats.dark_count > 0)
  assert_true(ean_stats.light_count > 0)
  assert_true(ean_stats.transitions > 40)
  let itf = @moonbarcode.encode(@moonbarcode.ITF14, "12345678901231").unwrap()
  let itf_stats = @moonbarcode.analyze_modules(itf.modules)
  assert_eq(itf_stats.narrowest_run, 1)
  assert_eq(itf_stats.widest_run, 3)
}
