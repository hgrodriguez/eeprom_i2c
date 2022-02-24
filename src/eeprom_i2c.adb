with HAL.I2C;

with EEPROM_I2C.Eight_Bits.MC24XX01;

package body EEPROM_I2C is

   function Write_Byte (This : in out RP.I2C_Master.I2C_Master_Port;
                         A    : HAL.UInt16;
                         B    : Eeprom_Byte) return HAL.I2C.I2C_Status is
      Status : HAL.I2C.I2C_Status;
      Data   : HAL.I2C.I2C_Data := (1 => B);
   begin
      This.Mem_Write (Addr          => Eeprom_I2C_address,
                      Mem_Addr      => A,
                      Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
                      Data          => Data,
                      Status        => Status,
                      Timeout       => 0);
      return Status;
   end Write_Byte;

   function Read_Byte (This : in out RP.I2C_Master.I2C_Master_Port;
                        A    : HAL.UInt16;
                        B    : out Eeprom_Byte) return HAL.I2C.I2C_Status is
      Status : HAL.I2C.I2C_Status;
      Data   : HAL.I2C.I2C_Data (0 .. 0);
   begin
      This.Mem_Read (Addr          => Eeprom_I2C_address,
                     Mem_Addr      => A,
                     Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
                     Data          => Data,
                     Status        => Status,
                     Timeout       => 0);
      B := Data (0);
      return Status;
   end Read_Byte;

end EEPROM_I2C;
