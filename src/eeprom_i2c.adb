-----------------------------------------------------------------------------
--  Implementation for
--  Base class for the implementation of EEPROM memory connected via
--  I2C bus.
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--

package body EEPROM_I2C is

   use HAL;

   -----------------------------------------------------------------------------
   --  See .ads
   function Type_of_Chip (This : in out EEPROM_Memory) return EEPROM_Chip is
     (This.C_Type_of_Chip);

   -----------------------------------------------------------------------------
   --  See .ads
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory;
                                     Mem_Addr : HAL.UInt32)
                                     return Boolean is
     (if Mem_Addr <= This.C_Max_Byte_Address then True else False);

   -----------------------------------------------------------------------------
   --  See .ads
   function Mem_Addr_Size (This : in out EEPROM_Memory)
                           return HAL.I2C.I2C_Memory_Address_Size is
     (This.C_Memory_Address_Size);

   -----------------------------------------------------------------------------
   --  See .ads
   function Size_In_Bytes (This : in out EEPROM_Memory)
                           return HAL.UInt32 is
     (This.C_Size_In_Bytes);

   -----------------------------------------------------------------------------
   --  See .ads
   function Size_In_Bits (This : in out EEPROM_Memory)
                          return HAL.UInt32 is
     (This.C_Size_In_Bits);

   -----------------------------------------------------------------------------
   --  See .ads
   function Number_Of_Blocks (This : in out EEPROM_Memory)
                              return HAL.UInt16 is
     (This.C_Number_Of_Blocks);

   -----------------------------------------------------------------------------
   --  See .ads
   function Bytes_Per_Block (This : in out EEPROM_Memory)
                             return HAL.UInt32 is
     (This.C_Bytes_Per_Block);

   -----------------------------------------------------------------------------
   --  See .ads
   function Number_Of_Pages (This : in out EEPROM_Memory)
                             return HAL.UInt16 is
     (This.C_Number_Of_Pages);

   -----------------------------------------------------------------------------
   --  See .ads
   function Bytes_Per_Page (This : in out EEPROM_Memory)
                            return HAL.UInt16 is
     (This.C_Bytes_Per_Page);

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Read (This       : in out EEPROM_Memory'Class;
                   Mem_Addr   : HAL.UInt32;
                   Data       : out HAL.I2C.I2C_Data;
                   Status     : out EEPROM_Operation_Result;
                   Timeout_MS : Natural := 1000) is
      I2C_Status            : HAL.I2C.I2C_Status;
      Effective_I2C_Address : EEPROM_Effective_Address;

      M_A        : HAL.UInt32 := Mem_Addr;
      Data_1     : HAL.I2C.I2C_Data (1 .. 1);

      use HAL.I2C;
   begin
      if not This.Is_Valid_Memory_Address (Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      for Idx in Data'First .. Data'Last loop
         Effective_I2C_Address := This.Construct_I2C_Address (M_A);
         This.
           I2C_Port.all.
             Mem_Read (Addr          => Effective_I2C_Address.I2C_Address,
                       Mem_Addr      => Effective_I2C_Address.Mem_Addr,
                       Mem_Addr_Size => This.C_Memory_Address_Size,
                       Data          => Data_1,
                       Status        => I2C_Status,
                       Timeout       => Timeout_MS);
         Status.I2C_Status := I2C_Status;
         if Status.I2C_Status /= HAL.I2C.Ok then
            Status.E_Status := I2C_Not_Ok;
            return;
         end if;
         Data (Idx) := Data_1 (1);
         M_A := M_A + 1;
      end loop;

      Status.I2C_Status := I2C_Status;
      if Status.I2C_Status /= HAL.I2C.Ok then
         Status.E_Status := I2C_Not_Ok;
      else
         Status.E_Status := Ok;
      end if;
   end Read;

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Write (This       : in out EEPROM_Memory'Class;
                    Mem_Addr   : HAL.UInt32;
                    Data       : HAL.I2C.I2C_Data;
                    Status     : out EEPROM_Operation_Result;
                    Timeout_MS : Natural := 1000) is
      I2C_Status            : HAL.I2C.I2C_Status;
      Effective_I2C_Address : EEPROM_Effective_Address;

      M_A        : HAL.UInt32 := Mem_Addr;
      Data_1     : HAL.I2C.I2C_Data (1 .. 1);

      use HAL.I2C;
   begin
      if not Is_Valid_Memory_Address (This, Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      --  The data sheet has a t_WC (write cycle time) specified X ms
      --  for any write
      --  This write can be a byte or a page, but after one write,
      --  the chip needs some time to write the data internally
      --  the code below is working, but very slow
      --  optmization could be done by writing pages of data instead
      --  every byte
      --  basic functionality, which works
      for Idx in Data'First .. Data'Last loop
         Data_1 (1) := Data (Idx);
         Effective_I2C_Address := This.Construct_I2C_Address (M_A);
         This.
           I2C_Port.all.
             Mem_Write (Addr          => Effective_I2C_Address.I2C_Address,
                        Mem_Addr      => Effective_I2C_Address.Mem_Addr,
                        Mem_Addr_Size => This.C_Memory_Address_Size,
                        Data          => Data_1,
                        Status        => I2C_Status,
                        Timeout       => Timeout_MS);
         Status.I2C_Status := I2C_Status;
         if Status.I2C_Status /= HAL.I2C.Ok then
            Status.E_Status := I2C_Not_Ok;
            return;
         end if;
         This.C_Delay_Callback.all (This.C_Write_Delay_MS);
         M_A := M_A + 1;
      end loop;
      Status.E_Status := Ok;
   end Write;

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Wipe (This   : in out EEPROM_Memory'Class;
                   Status : out EEPROM_Operation_Result) is
      --  definition for one page of EEPROM, hoping, that one page
      --  never kills the stack
      Wipe_Data : constant HAL.I2C.I2C_Data
        (1
         ..
           Integer (This.C_Bytes_Per_Page))
          := (others => 16#FF#);

      Page_Base_Address : HAL.UInt32 := 16#0000_0000#;
   begin
      --  loop over all pages
      for P in 1 .. This.C_Number_Of_Pages loop
         --  write one full page per cycle
         This.Write (Mem_Addr => Page_Base_Address,
                     Data     => Wipe_Data,
                     Status   => Status);
         if Status.E_Status /= Ok then
            return;
         end if;
         Page_Base_Address := Page_Base_Address
           + HAL.UInt32 (This.C_Bytes_Per_Page);
      end loop;
   end Wipe;

   -----------------------------------------------------------------------------
   --  See .ads
   function Construct_I2C_Address (This       : in out EEPROM_Memory'Class;
                                   Mem_Addr   : HAL.UInt32)
                                   return EEPROM_Effective_Address is
      XX            : HAL.UInt16;
      Result        : EEPROM_Effective_Address
        := (I2C_Address => This.I2C_Addr,
            Mem_Addr => HAL.UInt16 (Mem_Addr));
      use HAL.I2C;
   begin
      if This.C_Memory_Address_Size = HAL.I2C.Memory_Size_16b then
         --  nothing to do, as there are no blocks to consider
         return Result;
      end if;

      --  This.C_Memory_Address_Size = HAL.I2C.Memory_Size_8b
      --  there are chips, which have the extension of more then 8 bits
      --  of mem address as blocks in the I2C address
      --  this needs computing
      if This.C_Number_Of_Blocks > 1 then
         XX := HAL.UInt16 (Shift_Right (Mem_Addr, 8));
         XX := Shift_Left (XX, 1);
         Result.I2C_Address := Result.I2C_Address
           or HAL.I2C.I2C_Address (XX and 16#3FF#);
      end if;
      Result.Mem_Addr :=  HAL.UInt16 (Mem_Addr and 16#FF#);
      return Result;
   end Construct_I2C_Address;

end EEPROM_I2C;
