package body EEPROM_I2C.Eight_Bits.MC24XX01 is

   function Create (I2C_Port : not null HAL.I2C.Any_I2C_Port;
                    I2C_Addr : HAL.I2C.I2C_Address) return EEPROM_Memory_8Bits_MC24XX01 is
      This : EEPROM_Memory_8Bits_MC24XX01;
   begin
      This.Super (Chip => EEPROM_I2C.EEC_MC24XX01,
                  Port => I2C_Port,
                  Addr => I2C_Addr);
      return This;
   end Create;

   overriding
   function Address_Size (This : in out EEPROM_Memory_8Bits_MC24XX01)
                          return HAL.I2C.I2C_Memory_Address_Size is
     (This.Size);

   overriding
   function Size_In_Bytes (This : in out EEPROM_Memory_8Bits_MC24XX01)
                           return HAL.UInt32 is
     (This.Size_In_Bytes);

   overriding
   function Size_In_Bits (This : in out EEPROM_Memory_8Bits_MC24XX01)
                          return HAL.UInt32 is
      (This.Size_In_Bits);

   overriding
   function Number_Of_Pages (This : in out EEPROM_Memory_8Bits_MC24XX01)
                             return HAL.UInt16 is
     (This.Pages);

   overriding
   function Bytes_Per_Page (This : in out EEPROM_Memory_8Bits_MC24XX01)
                            return HAL.UInt16 is
     (This.Bytes_Per_Page);

end EEPROM_I2C.Eight_Bits.MC24XX01;
