-----------------------------------------------------------------------------
--  Implementation of reading one byte from an EEPROM using I2C
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.I2C;

with RP.GPIO;

with Pico;

with EEPROM_I2C.MC24XX01;

with Delay_Provider;

with Helpers;

procedure Read_One_Byte is

   procedure Read_EEPROM;

   --  Definitions for the EEPROM read byte to access
   MY_ADDR      : constant HAL.UInt16 := 37;
   Read_Data    : HAL.I2C.I2C_Data (0 .. 0);
   My_Byte      : HAL.UInt8;
   pragma Warnings (Off, My_Byte);

   --  Trigger button when to read the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;
   Button_State : Boolean;

   procedure Read_EEPROM is
      Eeprom : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01
        (Delay_Provider.Delay_MS'Access,
         EEPROM_I2C.MC24XX01.I2C_DEFAULT_ADDRESS,
         Helpers.Eeprom_I2C_Port'Access);
      Status : EEPROM_I2C.EEPROM_Operation_Result;
   begin
      --  read indefinitely to watch the oscilloscope
      loop
         --  just some visual help
         Pico.LED.Clear;

         --  wait for the trigger to hit to start the read
         loop
            Button_State := RP.GPIO.Get (Button);
            exit when Button_State;
         end loop;
         --  just some visual help
         Pico.LED.Set;

         --  read one byte from the EEPROM
         EEPROM_I2C.Read (Eeprom,
                          Mem_Addr   => MY_ADDR,
                          Data       => Read_Data,
                          Status     => Status,
                          Timeout_MS => 0);

         --  fetch the one byte I am interested in
         My_Byte := Read_Data (0);

         --  wait for the trigger to release to read another cycle
         loop
            Button_State := RP.GPIO.Get (Button);
            exit when not Button_State;
         end loop;
         --  just some visual help
         Pico.LED.Clear;

      end loop;
   end Read_EEPROM;

begin
   Helpers.Initialize_I2C;

   --  define a trigger input to enable oscilloscope tracking
   RP.GPIO.Configure (This => Button,
                      Mode => RP.GPIO.Input,
                      Pull => RP.GPIO.Pull_Down,
                      Func => RP.GPIO.SIO);

   --  just some visual help
   Pico.LED.Set;

   Read_EEPROM;

end Read_One_Byte;
