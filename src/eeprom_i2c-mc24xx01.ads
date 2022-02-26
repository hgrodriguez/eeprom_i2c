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
   --  This is the EEPROM definition.
   --  We keep it as closed as possible to ensure, that changes have minimal
   --  ripple effect throughout.
   type EEPROM_Memory_MC24XX01 is new EEPROM_Memory with private;

   -----------------------------------------------------------------------------
   --  This is the default I2C address of the EEPROM.
   DEFAULT_ADDRESS : constant HAL.I2C.I2C_Address := 2#1010_0000#;

   -----------------------------------------------------------------------------
   --  Creates one concreate MicroChip 24XX01/24LC01B EEPROM.
   --  I2C_Port : the I2C port the EEPROM is connected to
   --  I2C_Addr : the address of the EEPROM
   function Create (I2C_Port : not null HAL.I2C.Any_I2C_Port;
                    I2C_Addr : HAL.I2C.I2C_Address := DEFAULT_ADDRESS)
                    return EEPROM_Memory_MC24XX01;

   -----------------------------------------------------------------------------
   --  See package specification for base class
   overriding
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory_MC24XX01;
                                     Mem_Addr : HAL.UInt16)
                                     return Boolean;

   -----------------------------------------------------------------------------
   --  See package specification for base class
   overriding
   function Address_Size (This : in out EEPROM_Memory_MC24XX01)
                          return HAL.I2C.I2C_Memory_Address_Size;
   -----------------------------------------------------------------------------
   --  See package specification for base class
   overriding
   function Size_In_Bytes (This : in out EEPROM_Memory_MC24XX01)
                           return HAL.UInt32;

   -----------------------------------------------------------------------------
   --  See package specification for base class
   overriding
   function Size_In_Bits (This : in out EEPROM_Memory_MC24XX01)
                          return HAL.UInt32;

   -----------------------------------------------------------------------------
   --  See package specification for base class
   overriding
   function Number_Of_Pages (This : in out EEPROM_Memory_MC24XX01)
                             return HAL.UInt16;

   -----------------------------------------------------------------------------
   --  See package specification for base class
   overriding
   function Bytes_Per_Page (This : in out EEPROM_Memory_MC24XX01)
                            return HAL.UInt16;

private
   -----------------------------------------------------------------------------
   --  The address range this EEPROM supports.
   subtype Address_Range is HAL.UInt16 range 16#00# .. 16#7F#;

   type EEPROM_Memory_MC24XX01 is new EEPROM_Memory with record
      Size           : HAL.I2C.I2C_Memory_Address_Size := HAL.I2C.Memory_Size_8b;
      Size_In_Bytes  : HAL.UInt32 := 128;
      Size_In_Bits   : HAL.UInt32 := 1024;
      Pages          : HAL.UInt16 := 16;
      Bytes_Per_Page : HAL.UInt16 := 8;
   end record;

end EEPROM_I2C.MC24XX01;
