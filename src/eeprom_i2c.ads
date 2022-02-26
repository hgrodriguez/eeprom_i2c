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

   type EEPROM_Chip is (EEC_MC24XX01);

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

   type EEPROM_Status is (Ok, Address_Out_Of_Range, I2C_Not_Ok);
   type EEPROM_Record is record
      E_Status   : EEPROM_Status;
      I2C_Status : HAL.I2C.I2C_Status;
   end record;

   function Address_Size (This : in out EEPROM_Memory)
                          return HAL.I2C.I2C_Memory_Address_Size is abstract;

   function Size_In_Bytes (This : in out EEPROM_Memory)
                           return HAL.UInt32 is abstract;

   function Size_In_Bits (This : in out EEPROM_Memory)
                          return HAL.UInt32 is abstract;

   function Number_Of_Pages (This : in out EEPROM_Memory)
                             return HAL.UInt16 is abstract;

   function Bytes_Per_Page (This : in out EEPROM_Memory)
                            return HAL.UInt16 is abstract;

   procedure Read (This     : in out EEPROM_Memory;
                   Mem_Addr : HAL.UInt16;
                   Data     : out HAL.I2C.I2C_Data;
                   Status   : out EEPROM_Record;
                   Timeout  : Natural := 1000);

   procedure Write (This     : in out EEPROM_Memory;
                    Mem_Addr : HAL.UInt16;
                    Data     : HAL.I2C.I2C_Data;
                    Status   : out EEPROM_Record;
                    Timeout  : Natural := 1000);

private
   type EEPROM_Memory is abstract tagged record
      Chip : EEPROM_Chip;
      Port : HAL.I2C.Any_I2C_Port;
      Addr : HAL.I2C.I2C_Address;
   end record;

   -----------------------------------------------------------------------------
   --  Simulating a super() from other OO languages
   --  Sets all the, at this level, known attributes
   procedure Super (This : in out EEPROM_Memory;
                    Chip : EEPROM_Chip;
                    Port : HAL.I2C.Any_I2C_Port;
                    Addr : HAL.I2C.I2C_Address);

end EEPROM_I2C;
