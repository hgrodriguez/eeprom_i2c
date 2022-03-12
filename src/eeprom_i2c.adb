-----------------------------------------------------------------------------
--  Implementation for
--  Base class for the implementation of EEPROM memory connected via
--  I2C bus.
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

package body EEPROM_I2C is

   use HAL;

   -----------------------------------------------------------------------------
   --  See .ads
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory;
                                     Mem_Addr : HAL.UInt16)
                                     return Boolean is
     (if Mem_Addr > This.Max_Address then False else True);

   -----------------------------------------------------------------------------
   --  See .ads
   function Address_Size (This : in out EEPROM_Memory)
                          return HAL.I2C.I2C_Memory_Address_Size is
     (This.Mem_Addr_Size);

   -----------------------------------------------------------------------------
   --  See .ads
   function Size_In_Bytes (This : in out EEPROM_Memory)
                           return HAL.UInt32 is
     (This.Size_In_Bytes);

   -----------------------------------------------------------------------------
   --  See .ads
   function Size_In_Bits (This : in out EEPROM_Memory)
                          return HAL.UInt32 is
     (This.Size_In_Bits);

   -----------------------------------------------------------------------------
   --  See .ads
   function Number_Of_Pages (This : in out EEPROM_Memory)
                             return HAL.UInt16 is
     (This.Num_Of_Pages);

   -----------------------------------------------------------------------------
   --  See .ads
   function Bytes_Per_Page (This : in out EEPROM_Memory)
                            return HAL.UInt16 is
     (This.Bytes_Per_Page);

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Read (This     : in out EEPROM_Memory'Class;
                   Mem_Addr : HAL.UInt16;
                   Data     : out HAL.I2C.I2C_Data;
                   Status   : out EEPROM_Operation_Result;
                   Timeout  : Natural := 1000) is
      I2C_Status : HAL.I2C.I2C_Status;
      use HAL.I2C;
   begin
      if not This.Is_Valid_Memory_Address (Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      This.I2C_Port.all.Mem_Read (Addr          => This.I2C_Addr,
                              Mem_Addr      => Mem_Addr,
                              Mem_Addr_Size => This.Mem_Addr_Size,
                              Data          => Data,
                              Status        => I2C_Status,
                              Timeout       => Timeout);

      Status.I2C_Status := I2C_Status;
      if Status.I2C_Status /= HAL.I2C.Ok then
         Status.E_Status := I2C_Not_Ok;
      else
         Status.E_Status := Ok;
      end if;
   end Read;

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Write (This     : in out EEPROM_Memory'Class;
                    Mem_Addr : HAL.UInt16;
                    Data     : HAL.I2C.I2C_Data;
                    Status   : out EEPROM_Operation_Result;
                    Timeout  : Natural := 1000) is
      I2C_Status : HAL.I2C.I2C_Status;
      use HAL.I2C;
   begin
      if not Is_Valid_Memory_Address (This, Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      This.I2C_Port.all.Mem_Write (Addr          => This.I2C_Addr,
                               Mem_Addr      => Mem_Addr,
                               Mem_Addr_Size => This.Mem_Addr_Size,
                               Data          => Data,
                               Status        => I2C_Status,
                               Timeout       => Timeout);

      Status.I2C_Status := I2C_Status;
      if Status.I2C_Status /= HAL.I2C.Ok then
         Status.E_Status := I2C_Not_Ok;
      else
         Status.E_Status := Ok;
      end if;
   end Write;

end EEPROM_I2C;
