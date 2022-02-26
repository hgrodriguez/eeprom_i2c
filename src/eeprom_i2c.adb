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

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Read (This     : in out EEPROM_Memory;
                   Mem_Addr : HAL.UInt16;
                   Data     : out HAL.I2C.I2C_Data;
                   Status   : out EEPROM_Operation_Result;
                   Timeout  : Natural := 1000) is
      I2C_Status : HAL.I2C.I2C_Status;
      AS         : HAL.I2C.I2C_Memory_Address_Size;
      EEM        : EEPROM_Memory'Class := This;

      use HAL.I2C;
   begin
      if not EEM.Is_Valid_Memory_Address (Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      AS := EEM.Address_Size;
      This.Port.all.Mem_Read (Addr          => This.Addr,
                              Mem_Addr      => Mem_Addr,
                              Mem_Addr_Size => AS,
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
   procedure Write (This     : in out EEPROM_Memory;
                    Mem_Addr : HAL.UInt16;
                    Data     : HAL.I2C.I2C_Data;
                    Status   : out EEPROM_Operation_Result;
                    Timeout  : Natural := 1000) is
      I2C_Status : HAL.I2C.I2C_Status;
      AS         : HAL.I2C.I2C_Memory_Address_Size;
      EEM        : EEPROM_Memory'Class := This;

      use HAL.I2C;
   begin
      if not EEM.Is_Valid_Memory_Address (Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      AS := EEM.Address_Size;
      This.Port.all.Mem_Write (Addr          => This.Addr,
                               Mem_Addr      => Mem_Addr,
                               Mem_Addr_Size => AS,
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

   -----------------------------------------------------------------------------
   --  see .ads
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
