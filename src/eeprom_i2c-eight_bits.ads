with HAL.I2C;

package EEPROM_I2C.Eight_Bits is

   type EEPROM_Memory_8Bits is abstract new EEPROM_Memory with private;

   procedure Place_Holder;

private
   type EEPROM_Memory_8Bits is abstract new EEPROM_Memory with null record;

end EEPROM_I2C.Eight_Bits;
