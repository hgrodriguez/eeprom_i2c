package EEPROM_I2C.Eight_Bits.MC24XX01 is

   type EEPROM_Memory_8Bits_MC24XX01 is new EEPROM_Memory_8Bits with private;

   function Create (EC       : EEPROM_Chip;
                    I2C_Port : not null HAL.I2C.Any_I2C_Port;
                    I2C_Addr : HAL.I2C.I2C_Address) return EEPROM_Memory_8Bits_MC24XX01;

   overriding
   function Size_In_Bytes (This : in out EEPROM_Memory_8Bits_MC24XX01) return HAL.UInt32;

private
   type EEPROM_Memory_8Bits_MC24XX01 is new EEPROM_Memory_8Bits with record
      Size_In_Bytes  : HAL.UInt32 := 128;
      Size_In_Bits   : HAL.UInt32 := 128 * 8;
      Pages          : HAL.UInt16 := 8;
      Bytes_Per_Page : HAL.UInt16 := 16;
   end record;


end EEPROM_I2C.Eight_Bits.MC24XX01;
