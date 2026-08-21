///|
/// A contiguous run of light or dark modules.
pub struct ModuleRun {
  dark : Bool
  width : Int
} derive(Eq, Debug)

///|
/// Basic structural statistics for a barcode module stream.
pub struct ModuleStats {
  module_count : Int
  dark_count : Int
  light_count : Int
  transitions : Int
  narrowest_run : Int
  widest_run : Int
} derive(Eq, Debug)

///|
pub fn module_runs(modules : Array[Bool]) -> Array[ModuleRun] {
  let out : Array[ModuleRun] = []
  if modules.is_empty() {
    return out
  }
  let mut dark = modules[0]
  let mut width = 1
  for i = 1; i < modules.length(); i = i + 1 {
    if modules[i] == dark {
      width = width + 1
    } else {
      out.push({ dark, width })
      dark = modules[i]
      width = 1
    }
  }
  out.push({ dark, width })
  out
}

///|
pub fn analyze_modules(modules : Array[Bool]) -> ModuleStats {
  let runs = module_runs(modules)
  let mut dark_count = 0
  let mut narrowest = if runs.is_empty() { 0 } else { runs[0].width }
  let mut widest = 0
  for run in runs {
    if run.dark {
      dark_count = dark_count + run.width
    }
    if run.width < narrowest {
      narrowest = run.width
    }
    if run.width > widest {
      widest = run.width
    }
  }
  {
    module_count: modules.length(),
    dark_count,
    light_count: modules.length() - dark_count,
    transitions: if runs.is_empty() {
      0
    } else {
      runs.length() - 1
    },
    narrowest_run: narrowest,
    widest_run: widest,
  }
}

///|
pub fn modules_to_binary(modules : Array[Bool]) -> String {
  let out = Buffer()
  for bit in modules {
    out.write_byte(if bit { b'1' } else { b'0' })
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
pub fn modules_from_binary(value : String) -> Result[Array[Bool], String] {
  if value.is_empty() {
    return Err("module string must not be empty")
  }
  let out : Array[Bool] = []
  let bytes = @utf8.encode(value)
  for i = 0; i < bytes.length(); i = i + 1 {
    match bytes[i] {
      b'0' => out.push(false)
      b'1' => out.push(true)
      _ => return Err("invalid module character at position \{i}")
    }
  }
  Ok(out)
}

///|
pub fn reverse_modules(modules : Array[Bool]) -> Array[Bool] {
  let out : Array[Bool] = []
  for i = modules.length() - 1; i >= 0; i = i - 1 {
    out.push(modules[i])
  }
  out
}

///|
pub fn invert_modules(modules : Array[Bool]) -> Array[Bool] {
  let out : Array[Bool] = []
  for bit in modules {
    out.push(!bit)
  }
  out
}

///|
pub fn add_quiet_zone(modules : Array[Bool], width : Int) -> Array[Bool] {
  let quiet = if width < 0 { 0 } else { width }
  let out : Array[Bool] = []
  for i = 0; i < quiet; i = i + 1 {
    out.push(false)
  }
  for bit in modules {
    out.push(bit)
  }
  for i = 0; i < quiet; i = i + 1 {
    out.push(false)
  }
  out
}

///|
pub fn trim_quiet_zone(modules : Array[Bool]) -> Array[Bool] {
  let mut start = 0
  while start < modules.length() && !modules[start] {
    start = start + 1
  }
  let mut end = modules.length()
  while end > start && !modules[end - 1] {
    end = end - 1
  }
  let out : Array[Bool] = []
  for i = start; i < end; i = i + 1 {
    out.push(modules[i])
  }
  out
}

///|
pub fn hamming_distance(left : Array[Bool], right : Array[Bool]) -> Int? {
  if left.length() != right.length() {
    return None
  }
  let mut distance = 0
  for i = 0; i < left.length(); i = i + 1 {
    if left[i] != right[i] {
      distance = distance + 1
    }
  }
  Some(distance)
}
