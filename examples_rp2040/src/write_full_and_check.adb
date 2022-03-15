-----------------------------------------------------------------------------
--  Implementation of writing the full EEPROM using I2C
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL.I2C;

with RP.GPIO;

with Pico;

with Delay_Provider;
with EEPROM_I2C.MC24XX01;
with Helpers;

procedure Write_Full_And_Check is

   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Trigger button when to read/write the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;

   Eeprom       : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
     (Delay_Provider.Delay_MS'Access,
      EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
      Helpers.Eeprom_I2C_Port'Access);

   Ref_Data : HAL.I2C.I2C_Data (1 .. Integer (Eeprom.Size_In_Bytes));
   Byte     : HAL.UInt8;

   Read_Data : HAL.I2C.I2C_Data (1 .. Integer (Eeprom.Size_In_Bytes));

   EE_Status : EEPROM_I2C.EEPROM_Operation_Result;

   use HAL;

begin
   Helpers.Initialize (Eeprom_SDA,
                       Eeprom_SCL,
                       Button);

   --  just some visual help
   Pico.LED.Set;

   Byte := 0;
   for Idx in Ref_Data'First .. Ref_Data'Last loop
      Ref_Data (Idx) := Byte;
      Byte := Byte + 1;
   end loop;
   EEPROM_I2C.Read (Eeprom,
                    Mem_Addr   => 0,
                    Data       => Read_Data,
                    Status     => EE_Status,
                    Timeout_MS => 0);

   EEPROM_I2C.Write (Eeprom,
                     Mem_Addr   => 0,
                     Data       => Ref_Data,
                     Status     => EE_Status,
                     Timeout_MS => 0);

   EEPROM_I2C.Read (Eeprom,
                    Mem_Addr   => 0,
                    Data       => Read_Data,
                    Status     => EE_Status,
                    Timeout_MS => 0);
   for Idx in Ref_Data'First .. Ref_Data'Last loop
      if Read_Data (Idx) /= Ref_Data (Idx) then
         loop
            Pico.LED.Clear;
         end loop;
      end if;
   end loop;

   EEPROM_I2C.Wipe (This   => Eeprom,
                    Status => EE_Status);

end Write_Full_And_Check;
