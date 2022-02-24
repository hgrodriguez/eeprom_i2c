-----------------------------------------------------------------------------
--  ???
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.I2C;

with RP.I2C_Master;

package EEPROM_I2C is

   type EEPROM_Chip is (MC24XX01);

   use HAL;

   Eeprom_I2C_address : constant HAL.I2C.I2C_Address := 2#1010_0000#;

   subtype Eeprom_Byte is HAL.UInt8;

   subtype Address_Range is HAL.UInt16 range 16#00# .. 16#7F#;

   function Write_Byte (This : in out RP.I2C_Master.I2C_Master_Port;
                        A    : HAL.UInt16;
                        B    : Eeprom_Byte) return HAL.I2C.I2C_Status;
   function Read_Byte (This : in out RP.I2C_Master.I2C_Master_Port;
                       A    : HAL.UInt16;
                       B    : out Eeprom_Byte) return HAL.I2C.I2C_Status;

   -----------------------------------------------------------------------------
   --
   --
   type EEPROM_Memory is abstract tagged private;
   type Any_EEPROM_Memory is access all EEPROM_Memory'Class;

   type EEPROM_Status is (Ok, I2C_Not_Ok, Address_Out_Of_Range);
   type EEPROM_Record is record
      E_Status   : EEPROM_Status;
      I2C_Status : HAL.I2C.I2C_Status;
   end record;

   type EEPROM_Write is not null access
     procedure (This          : in out EEPROM_Memory;
                Mem_Addr      : HAL.UInt16;
                Data          : HAL.I2C.I2C_Data;
                Status        : out EEPROM_Record;
                Timeout       : Natural := 1000);

   type EEPROM_Read is not null access
     procedure (This          : in out EEPROM_Memory;
                Mem_Addr      : HAL.UInt16;
                Data          : out HAL.I2C.I2C_Data;
                Status        : out EEPROM_Record;
                Timeout       : Natural := 1000);

   function Size_In_Bytes (This : in out EEPROM_Memory) return HAL.UInt32 is abstract;

   private
   type EEPROM_Memory is abstract tagged record
         Chip : EEPROM_Chip;
         Port : HAL.I2C.Any_I2C_Port;
         Addr : HAL.I2C.I2C_Address;
      end record;

end EEPROM_I2C;
