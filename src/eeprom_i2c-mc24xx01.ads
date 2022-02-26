with HAL.I2C;

package EEPROM_I2C.MC24XX01 is

   type EEPROM_Memory_MC24XX01 is new EEPROM_Memory with private;

   function Create (I2C_Port : not null HAL.I2C.Any_I2C_Port;
                    I2C_Addr : HAL.I2C.I2C_Address) return EEPROM_Memory_MC24XX01;

   overriding
   function Address_Size (This : in out EEPROM_Memory_MC24XX01)
                          return HAL.I2C.I2C_Memory_Address_Size;
   overriding
   function Size_In_Bytes (This : in out EEPROM_Memory_MC24XX01)
                           return HAL.UInt32;

   overriding
   function Size_In_Bits (This : in out EEPROM_Memory_MC24XX01)
                          return HAL.UInt32;

   overriding
   function Number_Of_Pages (This : in out EEPROM_Memory_MC24XX01)
                             return HAL.UInt16;

   overriding
   function Bytes_Per_Page (This : in out EEPROM_Memory_MC24XX01)
                            return HAL.UInt16;

private
   type EEPROM_Memory_MC24XX01 is new EEPROM_Memory with record
      Size           : HAL.I2C.I2C_Memory_Address_Size := HAL.I2C.Memory_Size_8b;
      Size_In_Bytes  : HAL.UInt32 := 128;
      Size_In_Bits   : HAL.UInt32 := 1024;
      Pages          : HAL.UInt16 := 16;
      Bytes_Per_Page : HAL.UInt16 := 8;
   end record;

end EEPROM_I2C.MC24XX01;
