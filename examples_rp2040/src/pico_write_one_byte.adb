-----------------------------------------------------------------------------
--  Implementation of writing one byte from an EEPROM using I2C
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.I2C;

with RP.GPIO;

with Pico;

with Delay_Provider;
with EEPROM_I2C.MC24XX01;
with Helpers;

procedure Pico_Write_One_Byte is

   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Trigger button when to read/write the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;

   procedure Write_EEPROM;

   --  Definitions for the EEPROM read byte to access
   MY_ADDR      : constant HAL.UInt16 := 37;
   Read_Data    : HAL.I2C.I2C_Data (0 .. 0);
   My_Byte      : HAL.UInt8;
   pragma Warnings (Off, My_Byte);

   Write_Data    : constant HAL.I2C.I2C_Data (0 .. 0) := (0 => 16#A5#);

   procedure Write_EEPROM is
      Eeprom : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
        (Delay_Provider.Delay_MS'Access,
         EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
         Helpers.Eeprom_I2C_Port'Access);
      Status : EEPROM_I2C.EEPROM_Operation_Result;
   begin
      Helpers.Wait_For_Trigger_Fired;

      Eeprom.Write (Mem_Addr   => MY_ADDR,
                    Data       => Write_Data,
                    Status     => Status,
                    Timeout_MS => 0);

      Helpers.Wait_For_Trigger_Resume;

      --  read indefinitely to watch the oscilloscope
      loop
         --  just some visual help
         Pico.LED.Clear;

         Helpers.Wait_For_Trigger_Fired;
         --  just some visual help
         Pico.LED.Set;

         --  read one byte from the EEPROM
         Eeprom.Read (Mem_Addr   => MY_ADDR,
                      Data       => Read_Data,
                      Status     => Status,
                      Timeout_MS => 0);

         --  fetch the one byte I am interested in
         My_Byte := Read_Data (0);

         --  wait for the trigger to release to read another cycle
         Helpers.Wait_For_Trigger_Resume;
         --  just some visual help
         Pico.LED.Clear;

      end loop;
   end Write_EEPROM;

begin
   Helpers.Initialize (Eeprom_SDA,
                       Eeprom_SCL,
                       Button,
                      Pico.XOSC_Frequency);
   --  as always, visual help is appreciated
   Pico.LED.Configure (RP.GPIO.Output);

   --  just some visual help
   Pico.LED.Set;

   Write_EEPROM;

end Pico_Write_One_Byte;
