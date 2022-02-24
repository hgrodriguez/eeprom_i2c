package body EEPROM_I2C.Eight_Bits.MC24XX01 is

   function Create (EC       : EEPROM_Chip;
                    I2C_Port : not null HAL.I2C.Any_I2C_Port;
                    I2C_Addr : HAL.I2C.I2C_Address) return EEPROM_Memory_8Bits_MC24XX01 is
      Result : EEPROM_Memory_8Bits_MC24XX01;
   begin
      Result.Chip := EC;
      Result.Port := I2C_Port;
      Result.Addr := I2C_Addr;
      Result.Size := HAL.I2C.Memory_Size_8b;
      return Result;
   end Create;

   overriding
   function Size_In_Bytes (This : in out EEPROM_Memory_8Bits_MC24XX01) return HAL.UInt32 is
   begin
      return This.Size_In_Bytes;
   end Size_In_Bytes;

end EEPROM_I2C.Eight_Bits.MC24XX01;
