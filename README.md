# eeprom_i2c
This library
* implements the reading/writing for EEPROMs using the I2C interface.
* has no dependency on any other library except HAL.

Examples for different platforms are [available](https://github.com/hgrodriguez/eeprom_i2c_examples).

# Current status
Only one byte read/write is implemented and tested

Optimizations like page writing etc. are planned for future releases

# Chips implemented and tested

## 8-bits address range
MicroChip 24XX01/24LC01B: 1 kBit

MicroChip 24AA02/24LC02B: 2 kBit

MicroChip 24LC16B: 16 kBit

## 16-bits address range
MicroChip 24FC64: 64 kBit

MicroChip 24FC256: 256 kBit

MicroChip 24FC512: 512 kBit

# Versioning (Planning)
Major.Minor.Patch

## Major
Incrementing with every EEPROM chip implemented.

The idea is, that for every chip implemented, the [examples](https://github.com/hgrodriguez/eeprom_i2c_examples) are extended at the same time.

## Minor
Whenever there is something changed, which justifies a bump in the versioning, the minor part will be increased. This increment will continue across major versions.

## Patch
Whenver there is some progress, which does not justify a major or minor version bump, but should be versioned.
