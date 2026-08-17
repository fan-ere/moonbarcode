# Sources and Compliance Notes

`moonbarcode` is an original MoonBit implementation. The repository does not copy source code from another barcode library.

The implementation uses public barcode specifications and reference material to verify data formats, check digit rules, and module patterns:

- EAN-13 / EAN-8 / UPC-A: GS1 retail barcode rules and ISO/IEC 15420 concepts.
- ITF-14 / GTIN-14: GS1 GTIN check digit rules and Interleaved 2 of 5 module pattern conventions.
- Code 39: ISO/IEC 16388 concepts, including the mod-43 optional checksum.
- Code 93: public Code 93 character set and C/K checksum rules.
- Code 128 / GS1-128: ISO/IEC 15417 concepts, Code Set A/B/C switching, mod-103 checksum, and GS1 FNC1 usage.
- ISBN / ISSN / GTIN validation: public check digit formulas.

The script `scripts/gen_code128_table.py` generates internal Code 128 pattern data from embedded public pattern definitions. Generated data remains part of this Apache-2.0 project.

Test inputs are short synthetic examples or well-known public check digit examples. No private data, commercial code, or closed test fixture is included.
