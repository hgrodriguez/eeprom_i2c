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
   function Type_of_Chip (This : in out EEPROM_Memory) return EEPROM_Chip is
     (This.C_Type_of_Chip);

   -----------------------------------------------------------------------------
   --  See .ads
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory;
                                     Mem_Addr : HAL.UInt16)
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
                             return HAL.UInt16 is
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
                   Mem_Addr   : HAL.UInt16;
                   Data       : out HAL.I2C.I2C_Data;
                   Status     : out EEPROM_Operation_Result;
                   Timeout_MS : Natural := 1000) is
      I2C_Status            : HAL.I2C.I2C_Status;
      Effective_I2C_Address : EEPROM_Effective_Address;
      use HAL.I2C;
   begin
      if not This.Is_Valid_Memory_Address (Mem_Addr) then
         --  invalid address -> get out of here
         Status.E_Status := Address_Out_Of_Range;
         return;
      end if;

      declare
         M_A        : HAL.UInt16 := Mem_Addr;
         Data_1     : HAL.I2C.I2C_Data (1 .. 1);
      begin
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
      end;

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
                    Mem_Addr   : HAL.UInt16;
                    Data       : HAL.I2C.I2C_Data;
                    Status     : out EEPROM_Operation_Result;
                    Timeout_MS : Natural := 1000) is
      I2C_Status            : HAL.I2C.I2C_Status;
      Effective_I2C_Address : EEPROM_Effective_Address;

      M_A        : HAL.UInt16 := Mem_Addr;
      Data_1     : HAL.I2C.I2C_Data (1 .. 1);

      Mem_Starts_On_Page_Boundary : Boolean
        := Mem_Addr mod This.C_Bytes_Per_Page = 0;

      Next_Addr                   : HAL.UInt16;
      Left_Over                   : Natural;

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
      if False then
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
      else
         --  improved functionality, with page writing
         --  This is he overview of the implementation
         --  Case 1: Mem_Addr does not start on a page boundary
         --     Case 1.a: the size of the data is bigger or equal than
         --               the rest of the page:
         --               fill the page and go to Case 2.
         --     Case 1.b: the size of the data is smaller than the rest of the page
         --               just write the data end return
         --  Case 2: Mem_Addr starts on a page boundary
         --     Case 2.a: the data is bigger or equal than the page size:
         --               write the full page
         --               check again
         --     Case 2.b: the data is less than the page size
         --               write the rest of the data and return
         This.Write_Header_Bytes (Start_Addr => Mem_Addr,
                                  Data  => Data,
                                  Status  => Status,
                                  Timeout_MS => Timeout_MS,
                                  Next_Addr  => Next_Addr,
                                  Left_Over =>  Left_Over);
         if Status.E_Status /= Ok then
            return;
         end if;
         if Left_Over = 0 then
            return;
         end if;

         This.Write_Full_Pages (Start_Addr => Next_Addr,
                                Data => Data (Left_Over .. Data'Length - Left_Over - 1),
                                Status     => Status,
                                Timeout_MS => Timeout_MS,
                                Next_Addr => Next_Addr,
                                Left_Over => Left_Over);
         if Status.E_Status /= Ok then
            return;
         end if;
         if Left_Over = 0 then
            return;
         end if;

         This.Write_Tailing_Bytes (Mem_Addr => Next_Addr,
                                   Data      => Data (Left_Over .. Data'Length - Left_Over - 1),
                                   Status     => Status,
                                   Timeout_MS => Timeout_MS);
         if Status.E_Status /= Ok then
            return;
         end if;
      end if;
      Status.E_Status := Ok;
   end Write;

   -----------------------------------------------------------------------------
   --  see .ads
   procedure Wipe (This   : in out EEPROM_Memory'Class;
                   Status : out EEPROM_Operation_Result) is
      --  definition for one page of EEPROM, hoping, that one page
      --  never kills the stack
      Wipe_Data : constant HAL.I2C.I2C_Data (1
                                             ..
                                               Integer (This.C_Bytes_Per_Block))
        := (others => 16#FF#);

      Page_Base_Address : HAL.UInt16 := 16#0000#;
   begin
      --  loop over all pages
      for P in 1 .. This.Number_Of_Blocks loop
         --  write one full page per cycle
         This.Write (Mem_Addr => Page_Base_Address,
                     Data     => Wipe_Data,
                     Status   => Status);
         if Status.E_Status /= Ok then
            return;
         end if;
         Page_Base_Address := Page_Base_Address + This.C_Bytes_Per_Block;
      end loop;
   end Wipe;

   -----------------------------------------------------------------------------
   --  See .ads
   function Construct_I2C_Address (This       : in out EEPROM_Memory'Class;
                                   Mem_Addr   : HAL.UInt16)
                                   return EEPROM_Effective_Address is
      XX            : HAL.UInt16;
      Result        : EEPROM_Effective_Address := (I2C_Address => This.I2C_Addr,
                                                   Mem_Addr => Mem_Addr);
   begin
      if This.C_Number_Of_Blocks > 1 then
         XX := HAL.UInt16 (Shift_Right (Mem_Addr, 8));
         XX := HAL.UInt16 (Shift_Left (XX, 1));
         Result.I2C_Address := Result.I2C_Address or HAL.I2C.I2C_Address (XX and 16#3FF#);
      end if;
      Result.Mem_Addr :=  Mem_Addr and 16#FF#;
      return Result;
   end Construct_I2C_Address;

   -----------------------------------------------------------------------------
   --  See .ads
   procedure Write_Header_Bytes (This       : in out EEPROM_Memory'Class;
                                 Start_Addr : HAL.UInt16;
                                 Data       : HAL.I2C.I2C_Data;
                                 Status     : out EEPROM_Operation_Result;
                                 Timeout_MS : Natural := 1000;
                                 Next_Addr  : out HAL.UInt16;
                                 Left_Over  : out Natural) is
      Start_Addr_Is_On_Page_Boundary : constant Boolean := Start_Addr mod This.C_Bytes_Per_Page = 0;
   begin
      if not Start_Addr_Is_On_Page_Boundary then
         --  we have header bytes to write
         declare
            Effective_I2C_Address : EEPROM_Effective_Address;
            Running_Address       : HAL.UInt16 := Start_Addr;
            Bytes_Left_In_Page    : HAL.UInt16 := Start_Addr mod This.C_Bytes_Per_Page;
            --  Defines the maximum bytes to write as header bytes
            --  This is the minimum of either:
            --     Data'Size
            --  or
            --     Bytes left in page
            Max_Bytes_To_Write    : Natural;
            I2C_Status            : HAL.I2C.I2C_Status;
            use HAL.I2C;

         begin
            if Bytes_Left_In_Page < Data'Length then
               Max_Bytes_to_Write := Natural (Bytes_Left_In_Page);
            else
               Bytes_Left_In_Page := Data'Length;
            end if;
            for Idx in 1 .. Max_Bytes_To_Write loop
               Effective_I2C_Address := This.Construct_I2C_Address (Running_Address);
               This.
                 I2C_Port.all.
                   Mem_Write (Addr          => Effective_I2C_Address.I2C_Address,
                              Mem_Addr      => Effective_I2C_Address.Mem_Addr,
                              Mem_Addr_Size => This.C_Memory_Address_Size,
                              Data          => Data (Idx .. Idx),
                              Status        => I2C_Status,
                              Timeout       => Timeout_MS);
               Status.I2C_Status := I2C_Status;
               if Status.I2C_Status /= HAL.I2C.Ok then
                  Status.E_Status := I2C_Not_Ok;
                  Next_Addr := Running_Address;
                  Left_Over := Data'Length - Max_Bytes_To_Write;
                  return;
               end if;
               This.C_Delay_Callback.all (This.C_Write_Delay_MS);
               Running_Address := Running_Address + 1;
            end loop;
            Next_Addr := Running_Address;
            Left_Over := Data'Length - Max_Bytes_To_Write;
         end;
      else
         --  there are no header bytes to write
         --  just adjust the return values
         Next_Addr := Start_Addr;
         Left_Over := Data'Length;
         Status.E_Status := Ok;
      end if;
   end Write_Header_Bytes;


   -----------------------------------------------------------------------------
   --  See .ads
   procedure Write_Full_Pages (This       : in out EEPROM_Memory'Class;
                               Start_Addr : HAL.UInt16;
                               Data       : HAL.I2C.I2C_Data;
                               Status     : out EEPROM_Operation_Result;
                               Timeout_MS : Natural := 1000;
                               Next_Addr  : out HAL.UInt16;
                               Left_Over  : out Natural) is
      Effective_I2C_Address : EEPROM_Effective_Address;
      Running_Address       : HAL.UInt16 := Start_Addr;
      Number_Of_Full_Pages  : HAL.UInt16 := Data'Length / This.C_Bytes_Per_Page;
      I2C_Status            : HAL.I2C.I2C_Status;
      Start_Data_Index      : Natural := 1;
      End_Data_Index        : Natural := Start_Data_Index + Natural (This.C_Bytes_Per_Page) - 1;
      use HAL.I2C;

   begin
      Next_Addr := Start_Addr;
      Left_Over := Data'Length;
      for Idx in 1 .. Number_Of_Full_Pages loop
         Effective_I2C_Address := This.Construct_I2C_Address (Running_Address);
         This.
           I2C_Port.all.
             Mem_Write (Addr          => Effective_I2C_Address.I2C_Address,
                        Mem_Addr      => Effective_I2C_Address.Mem_Addr,
                        Mem_Addr_Size => This.C_Memory_Address_Size,
                        Data          => Data (Start_Data_Index .. End_Data_Index),
                        Status        => I2C_Status,
                        Timeout       => Timeout_MS);
         Status.I2C_Status := I2C_Status;
         if Status.I2C_Status /= HAL.I2C.Ok then
            Status.E_Status := I2C_Not_Ok;
            return;
         end if;
         This.C_Delay_Callback.all (This.C_Write_Delay_MS);
         Running_Address := Running_Address + This.C_Bytes_Per_Page;
         Start_Data_Index := Start_Data_Index + Natural (This.C_Bytes_Per_Page);
         End_Data_Index := Start_Data_Index + Natural (This.C_Bytes_Per_Page) - 1;
         Next_Addr := Next_Addr + This.C_Bytes_Per_Page;
         Left_Over := Left_Over - Natural (This.C_Bytes_Per_Page);
      end loop;
   end Write_Full_Pages;

   -----------------------------------------------------------------------------
   --  See .ads
   procedure Write_Tailing_Bytes (This       : in out EEPROM_Memory'Class;
                                  Mem_Addr   : HAL.UInt16;
                                  Data       : HAL.I2C.I2C_Data;
                                  Status     : out EEPROM_Operation_Result;
                                  Timeout_MS : Natural := 1000) is
      I2C_Status            : HAL.I2C.I2C_Status;
      Effective_I2C_Address : EEPROM_Effective_Address;

      M_A        : HAL.UInt16 := Mem_Addr;
      Data_1     : HAL.I2C.I2C_Data (1 .. 1);

      Mem_Starts_On_Page_Boundary : Boolean
        := Mem_Addr mod This.C_Bytes_Per_Page = 0;

      use HAL.I2C;
   begin
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
   end Write_Tailing_Bytes;

end EEPROM_I2C;
