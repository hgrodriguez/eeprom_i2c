-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

with RP.GPIO;
with RP.I2C_Master;

with Tiny;

with Delay_Provider;
with EEPROM_I2C.MC24XX01;
with Helpers;

procedure Tiny_Write_Full_And_Check is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames Tiny.I2C_1;

   --  EEPROM under test
   Eeprom_1K       : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
      Eeprom_I2C_Port'Access);

   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Tiny.GP26;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Tiny.GP27;

   --  Trigger button when to read/write the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Tiny.GP7;

   --  renames help to minimize the changes in the code below
   EEPROM : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01 renames Eeprom_1K;

   Ref_Data : HAL.I2C.I2C_Data (1 .. Integer (EEPROM.Size_In_Bytes));
   Byte     : HAL.UInt8;

   Read_Data : HAL.I2C.I2C_Data (1 .. Integer (EEPROM.Size_In_Bytes));

   EE_Status : EEPROM_I2C.EEPROM_Operation_Result;

   use HAL;

begin
   Tiny.Initialize;

   Helpers.Initialize (Eeprom_SDA,
                       Eeprom_SCL,
                       Eeprom_I2C_Port,
                       Button,
                       Tiny.XOSC_Frequency);

   --  as always, visual help is appreciated
   Tiny.LED_Red.Configure (RP.GPIO.Output);

   --  just some visual help
   Tiny.Switch_On (This => Tiny.LED_Red);

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
   for Idx in Ref_Data'First .. Ref_Data'Last loop
      if Read_Data (Idx) /= Ref_Data (Idx) then
         loop
            --  OOPs, something went wrong
            Tiny.Switch_Off (This => Tiny.LED_Red);
         end loop;
      end if;
   end loop;

   EEPROM_I2C.Wipe (This   => EEPROM,
                    Status => EE_Status);

end Tiny_Write_Full_And_Check;
