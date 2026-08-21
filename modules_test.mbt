///|
test "binary module conversion round trip" {
  let modules = [true, false, true, true, false]
  assert_eq(@moonbarcode.modules_to_binary(modules), "10110")
  assert_eq(@moonbarcode.modules_from_binary("10110"), Ok(modules))
  assert_true(@moonbarcode.modules_from_binary("") is Err(_))
  assert_true(@moonbarcode.modules_from_binary("101x") is Err(_))
}

///|
test "module runs and stats" {
  let modules = [true, true, false, true, true, true, false, false]
  let runs = @moonbarcode.module_runs(modules)
  assert_eq(runs.length(), 4)
  assert_true(runs[0].dark)
  assert_eq(runs[0].width, 2)
  assert_false(runs[3].dark)
  assert_eq(runs[3].width, 2)
  let stats = @moonbarcode.analyze_modules(modules)
  assert_eq(stats.module_count, 8)
  assert_eq(stats.dark_count, 5)
  assert_eq(stats.light_count, 3)
  assert_eq(stats.transitions, 3)
  assert_eq(stats.narrowest_run, 1)
  assert_eq(stats.widest_run, 3)
}

///|
test "quiet zone add and trim" {
  let core = [true, false, true]
  let padded = @moonbarcode.add_quiet_zone(core, 4)
  assert_eq(padded.length(), 11)
  assert_eq(@moonbarcode.trim_quiet_zone(padded), core)
  assert_eq(@moonbarcode.add_quiet_zone(core, -1), core)
  assert_eq(@moonbarcode.trim_quiet_zone([false, false]), [])
}

///|
test "reverse invert and Hamming distance" {
  assert_eq(@moonbarcode.reverse_modules([true, false, false]), [
    false, false, true,
  ])
  assert_eq(@moonbarcode.invert_modules([true, false, false]), [
    false, true, true,
  ])
  assert_eq(
    @moonbarcode.hamming_distance([true, false, true], [true, true, false]),
    Some(2),
  )
  assert_eq(@moonbarcode.hamming_distance([true], [true, false]), None)
}

///|
test "module stats handle empty stream" {
  let stats = @moonbarcode.analyze_modules([])
  assert_eq(stats.module_count, 0)
  assert_eq(stats.transitions, 0)
  assert_eq(stats.narrowest_run, 0)
  assert_eq(stats.widest_run, 0)
}

///|
test "single module has one run and no transition" {
  let stats = @moonbarcode.analyze_modules([true])
  assert_eq(stats.dark_count, 1)
  assert_eq(stats.light_count, 0)
  assert_eq(stats.transitions, 0)
  assert_eq(stats.narrowest_run, 1)
  assert_eq(stats.widest_run, 1)
}
