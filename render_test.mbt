///|
test "svg render has expected dimensions and bars" {
  let barcode = match @moonbarcode.encode(@moonbarcode.EAN13, "400638133393") {
    Ok(b) => b
    Err(_) => abort("encode failed")
  }
  let svg = @moonbarcode.render_svg(
    barcode,
    @moonbarcode.BarcodeOptions::default(),
  )
  // 95 modules * 2 px + quiet zones 2*10*2 px = 230 px wide.
  assert_true(svg.has_prefix("<svg"))
  assert_true(svg.contains("width=\"230\""))
  assert_true(svg.contains("<rect"))
  assert_true(svg.contains("4006381333931"))
  assert_true(svg.has_suffix("</svg>"))
}

///|
test "svg without text omits text element" {
  let barcode = match @moonbarcode.encode(@moonbarcode.EAN13, "400638133393") {
    Ok(b) => b
    Err(_) => abort("encode failed")
  }
  let opt = @moonbarcode.BarcodeOptions::new(show_text=false)
  let svg = @moonbarcode.render_svg(barcode, opt)
  assert_true(!svg.contains("<text"))
}

///|
test "ascii render matches module widths" {
  let barcode = match @moonbarcode.encode(@moonbarcode.EAN13, "400638133393") {
    Ok(b) => b
    Err(_) => abort("encode failed")
  }
  let opt = @moonbarcode.BarcodeOptions::new(module_width=1)
  let ascii = @moonbarcode.render_ascii(barcode, opt)
  // 95 modules * 1 char + quiet zones 2*10 chars + newline + 13-digit text.
  assert_eq(ascii.length(), 95 + 20 + 1 + 13)
  assert_true(ascii.has_suffix("4006381333931"))
}

///|
test "ansi render contains escape sequence" {
  let barcode = match @moonbarcode.encode(@moonbarcode.EAN13, "400638133393") {
    Ok(b) => b
    Err(_) => abort("encode failed")
  }
  let ansi = @moonbarcode.render_ansi(
    barcode,
    @moonbarcode.BarcodeOptions::default(),
  )
  assert_true(ansi.contains("\u{1b}[7m"))
}
