-----------------------------------------------------------------------------
--  Concrete implementation class for the MicroChip 24XX01/24LC01B EEPROM
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

package EEPROM_I2C.MC24XX01 is

   -----------------------------------------------------------------------------
   --  This is the default I2C address of the EEPROM.
   DEFAULT_ADDRESS : constant HAL.I2C.I2C_Address := 2#1010_0000#;

   -----------------------------------------------------------------------------
   --  This is the EEPROM definition.
   --  We keep it as closed as possible to ensure, that changes have minimal
   --  ripple effect throughout.
   type EEPROM_Memory_MC24XX01 (
                                --  the port where the EEPROM is connected to
                                I2C_Port : not null HAL.I2C.Any_I2C_Port
                               )
   is new EEPROM_Memory (
                         Type_of_Chip => EEC_MC24XX01,
                         Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
                         Size_In_Bytes => 128,
                         Size_In_Bits => 1024,
                         Num_Of_Pages => 16,
                         Bytes_Per_Page => 8,
                         Max_Address => 16#7F#,
                         I2C_Addr => DEFAULT_ADDRESS,
                         I2C_Port => I2C_Port
                        ) with null record;

end EEPROM_I2C.MC24XX01;
