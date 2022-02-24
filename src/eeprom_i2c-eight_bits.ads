with HAL.I2C;

package EEPROM_I2C.Eight_Bits is

   type EEPROM_Memory_8Bits is abstract new EEPROM_Memory with private;

private
   type EEPROM_Memory_8Bits is abstract new EEPROM_Memory with record
      Size : HAL.I2C.I2C_Memory_Address_Size := HAL.I2C.Memory_Size_8b;
   end record;

end EEPROM_I2C.Eight_Bits;
