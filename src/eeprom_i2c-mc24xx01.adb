-----------------------------------------------------------------------------
--  Concrete implementation class for the MicroChip 24XX01/24LC01B EEPROM
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL; use HAL;

package body EEPROM_I2C.MC24XX01 is

   -----------------------------------------------------------------------------
   --  See .ads
   function Create (I2C_Port : not null HAL.I2C.Any_I2C_Port;
                    I2C_Addr : HAL.I2C.I2C_Address := DEFAULT_ADDRESS)
                    return EEPROM_Memory_MC24XX01 is
      This : EEPROM_Memory_MC24XX01;
   begin
      This.Super (Chip => EEC_MC24XX01,
                  Port => I2C_Port,
                  Addr => I2C_Addr);
      return This;
   end Create;

   -----------------------------------------------------------------------------
   --  See .ads
   overriding
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory_MC24XX01;
                                     Mem_Addr : HAL.UInt16)
                                     return Boolean is
      (if Mem_Addr > Address_Range'Last then False else True);

   -----------------------------------------------------------------------------
   --  See .ads
   overriding
   function Address_Size (This : in out EEPROM_Memory_MC24XX01)
                          return HAL.I2C.I2C_Memory_Address_Size is
     (This.Size);

   -----------------------------------------------------------------------------
   --  See .ads
   overriding
   function Size_In_Bytes (This : in out EEPROM_Memory_MC24XX01)
                           return HAL.UInt32 is
     (This.Size_In_Bytes);

   -----------------------------------------------------------------------------
   --  See .ads
   overriding
   function Size_In_Bits (This : in out EEPROM_Memory_MC24XX01)
                          return HAL.UInt32 is
     (This.Size_In_Bits);

   -----------------------------------------------------------------------------
   --  See .ads
   overriding
   function Number_Of_Pages (This : in out EEPROM_Memory_MC24XX01)
                             return HAL.UInt16 is
     (This.Pages);

   -----------------------------------------------------------------------------
   --  See .ads
   overriding
   function Bytes_Per_Page (This : in out EEPROM_Memory_MC24XX01)
                            return HAL.UInt16 is
     (This.Bytes_Per_Page);


end EEPROM_I2C.MC24XX01;
