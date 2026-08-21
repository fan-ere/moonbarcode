///|
/// A parsed GS1 Application Identifier element.
pub struct Gs1Element {
  ai : String
  data : String
  title : String
  fixed_length : Bool
} derive(Eq, Debug)

///|
priv struct Gs1Spec {
  ai : String
  title : String
  min_length : Int
  max_length : Int
  numeric : Bool
}

///|
let gs1_specs : Array[Gs1Spec] = [
  { ai: "00", title: "SSCC", min_length: 18, max_length: 18, numeric: true },
  { ai: "01", title: "GTIN", min_length: 14, max_length: 14, numeric: true },
  { ai: "02", title: "CONTENT", min_length: 14, max_length: 14, numeric: true },
  {
    ai: "10",
    title: "BATCH/LOT",
    min_length: 1,
    max_length: 20,
    numeric: false,
  },
  { ai: "11", title: "PROD DATE", min_length: 6, max_length: 6, numeric: true },
  { ai: "12", title: "DUE DATE", min_length: 6, max_length: 6, numeric: true },
  { ai: "13", title: "PACK DATE", min_length: 6, max_length: 6, numeric: true },
  {
    ai: "15",
    title: "BEST BEFORE",
    min_length: 6,
    max_length: 6,
    numeric: true,
  },
  { ai: "16", title: "SELL BY", min_length: 6, max_length: 6, numeric: true },
  { ai: "17", title: "EXPIRY", min_length: 6, max_length: 6, numeric: true },
  { ai: "20", title: "VARIANT", min_length: 2, max_length: 2, numeric: true },
  { ai: "21", title: "SERIAL", min_length: 1, max_length: 20, numeric: false },
  { ai: "22", title: "CPV", min_length: 1, max_length: 20, numeric: false },
  { ai: "30", title: "COUNT", min_length: 1, max_length: 8, numeric: true },
  {
    ai: "37",
    title: "COUNT OF TRADE ITEMS",
    min_length: 1,
    max_length: 8,
    numeric: true,
  },
  {
    ai: "240",
    title: "ADDITIONAL ID",
    min_length: 1,
    max_length: 30,
    numeric: false,
  },
  {
    ai: "241",
    title: "CUSTOMER PART",
    min_length: 1,
    max_length: 30,
    numeric: false,
  },
  {
    ai: "242",
    title: "MTO VARIANT",
    min_length: 1,
    max_length: 6,
    numeric: false,
  },
  {
    ai: "250",
    title: "SECONDARY SERIAL",
    min_length: 1,
    max_length: 30,
    numeric: false,
  },
  {
    ai: "251",
    title: "REFERENCE TO SOURCE",
    min_length: 1,
    max_length: 30,
    numeric: false,
  },
  {
    ai: "400",
    title: "ORDER NUMBER",
    min_length: 1,
    max_length: 30,
    numeric: false,
  },
  { ai: "401", title: "GINC", min_length: 1, max_length: 30, numeric: false },
  { ai: "402", title: "GSIN", min_length: 17, max_length: 17, numeric: true },
  {
    ai: "410",
    title: "SHIP TO GLN",
    min_length: 13,
    max_length: 13,
    numeric: true,
  },
  {
    ai: "411",
    title: "BILL TO GLN",
    min_length: 13,
    max_length: 13,
    numeric: true,
  },
  {
    ai: "412",
    title: "PURCHASE FROM GLN",
    min_length: 13,
    max_length: 13,
    numeric: true,
  },
  {
    ai: "413",
    title: "SHIP FOR GLN",
    min_length: 13,
    max_length: 13,
    numeric: true,
  },
  {
    ai: "414",
    title: "PHYSICAL LOCATION GLN",
    min_length: 13,
    max_length: 13,
    numeric: true,
  },
  {
    ai: "420",
    title: "SHIP TO POST",
    min_length: 1,
    max_length: 20,
    numeric: false,
  },
  {
    ai: "421",
    title: "SHIP TO POST WITH COUNTRY",
    min_length: 4,
    max_length: 12,
    numeric: false,
  },
  {
    ai: "422",
    title: "ORIGIN COUNTRY",
    min_length: 3,
    max_length: 3,
    numeric: true,
  },
  {
    ai: "7001",
    title: "NATO STOCK NUMBER",
    min_length: 13,
    max_length: 13,
    numeric: true,
  },
  {
    ai: "7002",
    title: "MEAT CUT",
    min_length: 1,
    max_length: 30,
    numeric: false,
  },
  {
    ai: "7003",
    title: "EXPIRY WITH TIME",
    min_length: 10,
    max_length: 10,
    numeric: true,
  },
  {
    ai: "8001",
    title: "DIMENSIONS",
    min_length: 14,
    max_length: 14,
    numeric: true,
  },
  {
    ai: "8002",
    title: "CMT NUMBER",
    min_length: 1,
    max_length: 20,
    numeric: false,
  },
  { ai: "8003", title: "GRAI", min_length: 14, max_length: 30, numeric: false },
  { ai: "8004", title: "GIAI", min_length: 1, max_length: 30, numeric: false },
  {
    ai: "8005",
    title: "PRICE PER UNIT",
    min_length: 6,
    max_length: 6,
    numeric: true,
  },
  { ai: "8006", title: "ITIP", min_length: 18, max_length: 18, numeric: true },
  { ai: "8010", title: "CPID", min_length: 1, max_length: 30, numeric: false },
  {
    ai: "8011",
    title: "CPID SERIAL",
    min_length: 1,
    max_length: 12,
    numeric: true,
  },
  {
    ai: "8017",
    title: "GSRN PROVIDER",
    min_length: 18,
    max_length: 18,
    numeric: true,
  },
  {
    ai: "8018",
    title: "GSRN RECIPIENT",
    min_length: 18,
    max_length: 18,
    numeric: true,
  },
  {
    ai: "8020",
    title: "PAYMENT SLIP",
    min_length: 1,
    max_length: 25,
    numeric: false,
  },
]

///|
fn gs1_spec(ai : String) -> Gs1Spec? {
  for spec in gs1_specs {
    if spec.ai == ai {
      return Some(spec)
    }
  }
  // Measurement AIs 310n-369n carry six numeric digits. The final AI digit
  // specifies the decimal position.
  if ai.length() == 4 && ai >= "3100" && ai <= "3699" && is_all_digits(ai) {
    return Some({
      ai,
      title: "MEASUREMENT",
      min_length: 6,
      max_length: 6,
      numeric: true,
    })
  }
  // Monetary amount AIs 390n-395n are variable-length numeric fields.
  if ai.length() == 4 && ai >= "3900" && ai <= "3959" && is_all_digits(ai) {
    return Some({
      ai,
      title: "AMOUNT",
      min_length: 1,
      max_length: 15,
      numeric: true,
    })
  }
  None
}

///|
fn validate_gs1_value(spec : Gs1Spec, value : String) -> Result[Unit, String] {
  if value.length() < spec.min_length || value.length() > spec.max_length {
    return Err(
      "AI \{spec.ai} requires \{spec.min_length}-\{spec.max_length} characters",
    )
  }
  if spec.numeric && !is_all_digits(value) {
    return Err("AI \{spec.ai} requires numeric data")
  }
  let bytes = @utf8.encode(value)
  for byte in bytes {
    if byte < 32 || byte > 126 || byte == b'(' || byte == b')' {
      return Err("AI \{spec.ai} contains unsupported data")
    }
  }
  if spec.ai == "00" && !mod10_verify(value, 3, 1) {
    return Err("AI 00 SSCC check digit mismatch")
  }
  if (spec.ai == "01" || spec.ai == "02") && !mod10_verify(value, 3, 1) {
    return Err("AI \{spec.ai} GTIN check digit mismatch")
  }
  Ok(())
}

///|
fn find_closing_parenthesis(input : String, start : Int) -> Int? {
  for i = start; i < input.length(); i = i + 1 {
    if input[i] == ')' {
      return Some(i)
    }
  }
  None
}

///|
/// Parse human-readable GS1 element syntax such as
/// `(01)09506000134352(17)270101(10)LOT42`.
pub fn parse_gs1(input : String) -> Result[Array[Gs1Element], String] {
  let elements : Array[Gs1Element] = []
  let mut position = 0
  while position < input.length() {
    if input[position] != '(' {
      return Err("expected '(' at position \{position}")
    }
    let close = match find_closing_parenthesis(input, position + 1) {
      Some(index) => index
      None => return Err("missing ')' for AI at position \{position}")
    }
    let ai = input.sub(start=position + 1, end=close).to_owned()
    let spec = match gs1_spec(ai) {
      Some(value) => value
      None => return Err("unsupported GS1 application identifier: \{ai}")
    }
    let data_start = close + 1
    let mut data_end = input.length()
    for i = data_start; i < input.length(); i = i + 1 {
      if input[i] == '(' {
        data_end = i
        break
      }
    }
    let data = input.sub(start=data_start, end=data_end).to_owned()
    match validate_gs1_value(spec, data) {
      Err(message) => return Err(message)
      Ok(_) => ()
    }
    elements.push({
      ai,
      data,
      title: spec.title,
      fixed_length: spec.min_length == spec.max_length,
    })
    position = data_end
  }
  if elements.is_empty() {
    Err("GS1 input must contain at least one element")
  } else {
    Ok(elements)
  }
}

///|
/// Format parsed elements back to parenthesized human-readable GS1 syntax.
pub fn format_gs1(elements : Array[Gs1Element]) -> String {
  let out = Buffer()
  for element in elements {
    out.write_string_utf8("(\{element.ai})\{element.data}")
  }
  @utf8.decode_lossy(out.to_bytes())
}

///|
/// Build a GS1-128 payload. Variable-length fields are separated by FNC1
/// (`\u{1d}`) unless they are the final field.
pub fn gs1_128_payload(elements : Array[Gs1Element]) -> Result[String, String] {
  if elements.is_empty() {
    return Err("GS1 payload must contain at least one element")
  }
  let out = Buffer()
  for i = 0; i < elements.length(); i = i + 1 {
    let element = elements[i]
    let spec = match gs1_spec(element.ai) {
      Some(value) => value
      None =>
        return Err("unsupported GS1 application identifier: \{element.ai}")
    }
    match validate_gs1_value(spec, element.data) {
      Err(message) => return Err(message)
      Ok(_) => ()
    }
    out.write_string_utf8(element.ai)
    out.write_string_utf8(element.data)
    if spec.min_length != spec.max_length && i + 1 < elements.length() {
      out.write_byte(29)
    }
  }
  Ok(@utf8.decode_lossy(out.to_bytes()))
}

///|
/// Return true when a six-digit GS1 date has a valid month/day shape.
/// Day `00` is accepted because GS1 uses it for an unspecified day.
pub fn validate_gs1_date(value : String) -> Bool {
  if value.length() != 6 || !is_all_digits(value) {
    return false
  }
  let bytes = @utf8.encode(value)
  let month = (bytes[2] - b'0').to_int() * 10 + (bytes[3] - b'0').to_int()
  let day = (bytes[4] - b'0').to_int() * 10 + (bytes[5] - b'0').to_int()
  month >= 1 && month <= 12 && day >= 0 && day <= 31
}
