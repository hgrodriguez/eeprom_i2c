-----------------------------------------------------------------------------
--  Concrete implementation class for the MicroChip 24XX256 EEPROM
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

package EEPROM_I2C.MC24XX256 is

   -----------------------------------------------------------------------------
   --  This is the default I2C address of the EEPROM.
   I2C_DEFAULT_ADDRESS : constant HAL.I2C.I2C_Address := 2#1010_0000#;

   -----------------------------------------------------------------------------
   --  This is the EEPROM definition.
   --  We keep it as closed as possible to ensure, that changes have minimal
   --  ripple effect throughout.
   type EEPROM_Memory_MC24XX256
     (
      C_Delay_Callback : Proc_Delay_Callback_MS;
      --  the address of the EEPROM on the bus
      I2C_Addr         : HAL.I2C.I2C_Address;
      --  the port where the EEPROM is connected to
      I2C_Port         : not null HAL.I2C.Any_I2C_Port
     )
   is new EEPROM_Memory (
                         C_Type_of_Chip => EEC_MC24XX256,
                         C_Memory_Address_Size => HAL.I2C.Memory_Size_16b,
                         C_Size_In_Bytes => 32_768,
                         C_Size_In_Bits => 262_144,
                         C_Number_Of_Blocks => 1,
                         C_Bytes_Per_Block => 32_768,
                         C_Number_Of_Pages => 512,
                         C_Bytes_Per_Page => 64,
                         C_Max_Byte_Address => 32_767, --  Size in Bytes - 1
                         C_Write_Delay_MS => 5,
                         C_Delay_Callback => C_Delay_Callback,
                         I2C_Addr => I2C_Addr,
                         I2C_Port => I2C_Port
                        ) with null record;

end EEPROM_I2C.MC24XX256;
