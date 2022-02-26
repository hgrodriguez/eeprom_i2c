# eeprom_i2c
This library
* implements the reading/writing for EEPROMs using the I2C interface.
* has no dependency on any other library except HAL.

Inside the folder eeprom_i2c_examples are examples how to read/write data for different eeproms and for different boards.

# Current status
only one byte read/write is implemented and tested
only Raspberry Pi Pico is currently implemented for examples

# Chips implemented and tested

## 8-bits address range
MicroChip 24XX01/24LC01B

## 16-bits address range
None so far.

# Versioning (Planning)
Major.Minor.Patch

## Major
1 - Examples are available for Raspberry Pi Pico
2 - Examples are available for ItsyBitsy
3 - Examples are available for STM32F429 Discovery Board

## Minor
Incrementing with every EEPROM chip implemented. The idea is, that for every chip implemented, the examples are extended at the same time.

## Patch
Whenver there is some progress, which does not justify a major or minor version bump, but should be versioned.
