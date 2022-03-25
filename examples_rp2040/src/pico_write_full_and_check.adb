-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

with Pico;

with Delay_Provider;
with EEPROM_I2C.MC24XX01;
with EEPROM_I2C.MC24XX16;

with Helpers;

procedure Pico_Write_Full_And_Check is

   procedure Verify_Data;

   procedure Check_Full_Size;

   procedure Check_Header_Only;
   procedure Check_Header_And_Full_Pages;
   procedure Check_Header_And_Tailing;
   procedure Check_Header_And_Full_Pages_And_Tailing;

   procedure Check_Full_Pages;
   procedure Check_Full_Pages_And_Tailing;

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   --  EEPROM under test
   Eeprom_1K       : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
      Eeprom_I2C_Port'Access);

   Eeprom_16K       : EEPROM_I2C.MC24XX16.EEPROM_Memory_MC24XX16
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
      Eeprom_I2C_Port'Access);

   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Trigger button when to read/write the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;

   --  renames help to minimize the changes in the code below
   EEPROM : EEPROM_I2C.EEPROM_Memory'Class := Eeprom_1K;

   Ref_Data : HAL.I2C.I2C_Data (1 .. Integer (EEPROM.Size_In_Bytes));
   Byte     : HAL.UInt8;

   Read_Data : HAL.I2C.I2C_Data (1 .. Integer (EEPROM.Size_In_Bytes));

   EE_Status : EEPROM_I2C.EEPROM_Operation_Result;

   use HAL;

   procedure Verify_Data is
   begin
      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         if Read_Data (Idx) /= Ref_Data (Idx) then
            loop
               --  OOPs, something went wrong
               Pico.LED.Clear;
            end loop;
         end if;
      end loop;
   end Verify_Data;

   procedure Check_Full_Size is
   begin
      Byte := 0;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
         Byte := Byte + 1;
      end loop;
      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;

   end Check_Full_Size;

   procedure Check_Header_Only is
      Header_Data : HAL.I2C.I2C_Data (1
                                      ..
                                        Integer (EEPROM.C_Bytes_Per_Page) / 2);
      Mem_Addr    : constant HAL.UInt16 := EEPROM.C_Bytes_Per_Page / 2 - 1;
   begin
      Byte := 16#FF#;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
      end loop;

      Byte := 16#01#;
      for Idx in Header_Data'First .. Header_Data'Last loop
         Header_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx - 1) := Header_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;
   end Check_Header_Only;

   procedure Check_Header_And_Full_Pages is
      EE_Data : HAL.I2C.I2C_Data (1
                                      ..
                                    Integer (EEPROM.C_Bytes_Per_Page) / 2 +
                                 2 * Integer (EEPROM.C_Bytes_Per_Page));
      Mem_Addr    : constant HAL.UInt16 := EEPROM.C_Bytes_Per_Page / 2 - 1;
   begin
      Byte := 16#FF#;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
      end loop;

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx - 1) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;
   end Check_Header_And_Full_Pages;

   procedure Check_Header_And_Tailing is
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        1 * Integer (EEPROM.C_Bytes_Per_Page));
      Mem_Addr    : constant HAL.UInt16 := EEPROM.C_Bytes_Per_Page / 2 - 1;
   begin
      Byte := 16#FF#;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
      end loop;

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx - 1) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;
   end Check_Header_And_Tailing;

   procedure Check_Header_And_Full_Pages_And_Tailing is
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        2 * Integer (EEPROM.C_Bytes_Per_Page) +
                                     Integer (EEPROM.C_Bytes_Per_Page) / 2);
      Mem_Addr    : constant HAL.UInt16 := EEPROM.C_Bytes_Per_Page / 2 - 1;
   begin
      Byte := 16#FF#;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
      end loop;

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx - 1) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;
   end Check_Header_And_Full_Pages_And_Tailing;

   procedure Check_Full_Pages is
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        4 * Integer (EEPROM.C_Bytes_Per_Page));
      Mem_Addr    : constant HAL.UInt16 := 2 * EEPROM.C_Bytes_Per_Page;
   begin
      Byte := 16#FF#;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
      end loop;

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx - 1) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;
   end Check_Full_Pages;

   procedure Check_Full_Pages_And_Tailing is
      EE_Data     : HAL.I2C.I2C_Data (1
                                      ..
                                        2 * Integer (EEPROM.C_Bytes_Per_Page) +
                                        Integer (EEPROM.C_Bytes_Per_Page) / 2);
      Mem_Addr    : constant HAL.UInt16 := 2 * EEPROM.C_Bytes_Per_Page;
   begin
      Byte := 16#FF#;
      for Idx in Ref_Data'First .. Ref_Data'Last loop
         Ref_Data (Idx) := Byte;
      end loop;

      Byte := 16#01#;
      for Idx in EE_Data'First .. EE_Data'Last loop
         EE_Data (Idx) := Byte;
         Ref_Data (Integer (Mem_Addr) + Idx - 1) := EE_Data (Idx);
         Byte := Byte + 1;
      end loop;

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);

      EEPROM_I2C.Write (EEPROM,
                        Mem_Addr   => 0,
                        Data       => Ref_Data,
                        Status     => EE_Status,
                        Timeout_MS => 0);

      EEPROM_I2C.Read (EEPROM,
                       Mem_Addr   => 0,
                       Data       => Read_Data,
                       Status     => EE_Status,
                       Timeout_MS => 0);
      Verify_Data;
   end Check_Full_Pages_And_Tailing;

begin
   Helpers.Initialize (Eeprom_SDA,
                       Eeprom_SCL,
                       Eeprom_I2C_Port,
                       Button,
                       Pico.XOSC_Frequency);

   --  as always, visual help is appreciated
   Pico.LED.Configure (RP.GPIO.Output);

   --  just some visual help
   Pico.LED.Set;

   Check_Full_Size;
   EEPROM_I2C.Wipe (This   => EEPROM,
                    Status => EE_Status);

--     --  headers involved
--     Check_Header_Only;
--     EEPROM_I2C.Wipe (This   => EEPROM,
--                      Status => EE_Status);
--     Check_Header_And_Full_Pages;
--     EEPROM_I2C.Wipe (This   => EEPROM,
--                      Status => EE_Status);
--     Check_Header_And_Tailing;
--     EEPROM_I2C.Wipe (This   => EEPROM,
--                      Status => EE_Status);
--     Check_Header_And_Full_Pages_And_Tailing;
--     EEPROM_I2C.Wipe (This   => EEPROM,
--                      Status => EE_Status);
--
--     --  full pages involved
--     Check_Full_Pages;
--     EEPROM_I2C.Wipe (This   => EEPROM,
--                      Status => EE_Status);
--     Check_Full_Pages_And_Tailing;
--     EEPROM_I2C.Wipe (This   => EEPROM,
--                      Status => EE_Status);
end Pico_Write_Full_And_Check;
