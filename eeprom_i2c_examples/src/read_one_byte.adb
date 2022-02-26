-----------------------------------------------------------------------------
--  Implementation of reading one byte from an EEPROM using I2C
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.I2C;

with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;
with RP.Timer;

with Pico;

with EEPROM_I2C.MC24XX01;

procedure Read_One_Byte is

   procedure Initialize;
   procedure Read_EEPROM;

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   --  Definitions for the EEPROM read byte to access
   MY_ADDR      : constant HAL.UInt16 := 37;
   Read_Data    : HAL.I2C.I2C_Data (0 .. 0);
   My_Byte      : HAL.UInt8;

   --  Trigger button when to read the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;
   Button_State : Boolean;

   procedure Initialize is
      Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
      Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;
   begin
      --  standard initialization
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;

      --  as always, visual help is appreciated
      Pico.LED.Configure (RP.GPIO.Output);

      --  define a trigger input to enable oscilloscope tracking
      RP.GPIO.Configure (This => Button,
                         Mode => RP.GPIO.Input,
                         Pull => RP.GPIO.Pull_Down,
                         Func => RP.GPIO.SIO);

      --  configure the I2C port
      Eeprom_SDA.Configure (Mode => RP.GPIO.Output,
                            Pull => RP.GPIO.Pull_Up,
                            Func => RP.GPIO.I2C);
      Eeprom_SCL.Configure (Mode => RP.GPIO.Output,
                            Pull => RP.GPIO.Pull_Up,
                            Func => RP.GPIO.I2C);
      Eeprom_I2C_Port.Configure (Baudrate => 400_000);

   end Initialize;

   procedure Read_EEPROM is
      Eeprom : EEPROM_I2C.MC24XX01.EEPROM_Memory_MC24XX01;
      Status : EEPROM_I2C.EEPROM_Operation_Result;
   begin
      Eeprom := EEPROM_I2C
        .MC24XX01
            .Create (I2C_Port => Eeprom_I2C_Port'Access);
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
         Eeprom.Read (Mem_Addr => MY_ADDR,
                      Data     => Read_Data,
                      Status   => Status,
                      Timeout  => 0);

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
   Initialize;

   --  just some visual help
   Pico.LED.Set;

   Read_EEPROM;

end Read_One_Byte;
