with HAL.I2C;

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

   procedure Read (This     : in out EEPROM_Memory;
                   Mem_Addr : HAL.UInt16;
                   Data     : out HAL.I2C.I2C_Data;
                   Status   : out EEPROM_Record;
                   Timeout  : Natural := 1000) is
      I2C_Status : HAL.I2C.I2C_Status;
      AS         : HAL.I2C.I2C_Memory_Address_Size;
      X          : EEPROM_Memory'Class := This;
   begin
      AS := X.Address_Size;
      This.Port.all.Mem_Read (Addr          => This.Addr,
                              Mem_Addr      => Mem_Addr,
                              Mem_Addr_Size => AS,
                              Data          => Data,
                              Status        => I2C_Status,
                              Timeout       => Timeout);
      Status.E_Status := Ok;
      Status.I2C_Status := I2C_Status;
   end Read;

   procedure Write (This     : in out EEPROM_Memory;
                    Mem_Addr : HAL.UInt16;
                    Data     : HAL.I2C.I2C_Data;
                    Status   : out EEPROM_Record;
                    Timeout  : Natural := 1000) is
      I2C_Status : HAL.I2C.I2C_Status;
      AS         : HAL.I2C.I2C_Memory_Address_Size;
      X          : EEPROM_Memory'Class := This;
   begin
      AS := X.Address_Size;
      This.Port.all.Mem_Write (Addr          => This.Addr,
                               Mem_Addr      => Mem_Addr,
                               Mem_Addr_Size => AS,
                               Data          => Data,
                               Status        => I2C_Status,
                               Timeout       => Timeout);
      Status.E_Status := Ok;
      Status.I2C_Status := I2C_Status;
   end Write;

   procedure Super (This : in out EEPROM_Memory;
                    Chip : EEPROM_Chip;
                    Port : HAL.I2C.Any_I2C_Port;
                    Addr : HAL.I2C.I2C_Address) is
   begin
      This.Chip := Chip;
      This.Port := Port;
      This.Addr := Addr;
   end Super;

end EEPROM_I2C;
