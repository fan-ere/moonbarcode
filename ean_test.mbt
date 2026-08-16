///|
test "ean13 encodes 95 modules and appends check digit" {
  match @moonbarcode.encode(@moonbarcode.EAN13, "400638133393") {
    Ok(b) => {
      assert_eq(b.module_count(), 95)
      assert_eq(b.data, "4006381333931")
      assert_eq(b.symbology, @moonbarcode.EAN13)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "ean13 fixed 13 digits verifies check digit" {
  match @moonbarcode.encode(@moonbarcode.EAN13, "4006381333931") {
    Ok(b) => assert_eq(b.module_count(), 95)
    Err(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.EAN13, "4006381333930") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}

///|
test "ean13 rejects wrong length and non digits" {
  match @moonbarcode.encode(@moonbarcode.EAN13, "12345") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
  match @moonbarcode.encode(@moonbarcode.EAN13, "40063813339A3") {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}

///|
test "ean13 golden module pattern for 4006381333931" {
  match @moonbarcode.encode(@moonbarcode.EAN13, "4006381333931") {
    Ok(b) => {
      let pattern = modules_to_string(b.modules)
      assert_eq(
        pattern, "10100011010100111010111101111010001001011001101010100001010000101000010111010010000101100110101",
      )
    }
    Err(_) => assert_true(false)
  }
}

///|
test "ean8 encodes 67 modules and appends check digit" {
  match @moonbarcode.encode(@moonbarcode.EAN8, "9638507") {
    Ok(b) => {
      assert_eq(b.module_count(), 67)
      assert_eq(b.data, "96385074")
    }
    Err(_) => assert_true(false)
  }
}

///|
test "ean8 golden module pattern for 96385074" {
  match @moonbarcode.encode(@moonbarcode.EAN8, "96385074") {
    Ok(b) => {
      let pattern = modules_to_string(b.modules)
      assert_eq(
        pattern, "1010001011010111101111010110111010101001110111001010001001011100101",
      )
    }
    Err(_) => assert_true(false)
  }
}

///|
test "upca encodes 95 modules as ean13 with leading zero" {
  match @moonbarcode.encode(@moonbarcode.UPCA, "03600029145") {
    Ok(b) => {
      assert_eq(b.module_count(), 95)
      assert_eq(b.data, "036000291452")
      assert_eq(b.symbology, @moonbarcode.UPCA)
    }
    Err(_) => assert_true(false)
  }
}

///|
test "ean guards" {
  match @moonbarcode.encode(@moonbarcode.EAN13, "6901234567892") {
    Ok(b) => {
      let m = b.modules
      // Guard pattern is bar-space-bar: 101.
      assert_eq(m[0] && !m[1] && m[2], true)
      assert_eq(m[92] && !m[93] && m[94], true)
    }
    Err(_) => assert_true(false)
  }
}

///|
fn modules_to_string(modules : Array[Bool]) -> String {
  let out = Buffer()
  for m in modules {
    if m {
      out.write_byte(b'1')
    } else {
      out.write_byte(b'0')
    }
  }
  @utf8.decode_lossy(out.to_bytes())
}
