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

procedure Read_One_Byte is

   --  Address of the EEPROM device:
   --    16#50# ( * 2 = 16#A0#, as HAL.I2C includes the R / W bit)
   Eeprom_I2C_address : constant HAL.I2C.I2C_Address := 2#1010_0000#;

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   --  Definitions for the EEPROM read byte to access
   MY_ADDR      : constant HAL.UInt16 := 16#A5#;
   Read_Data    : HAL.I2C.I2C_Data (0 .. 0);
   My_Byte      : HAL.UInt8;
   Read_Status  : HAL.I2C.I2C_Status;

   --  Trigger button when to read the byte from the EEPROM
   --  This trigger is generated using a function generator
   --    providing a square signal with a settable frequency
   Button       : RP.GPIO.GPIO_Point renames Pico.GP16;
   Button_State : Boolean;

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

   --  just some visual help
   Pico.LED.Set;

   --  configure the I2C port
   Eeprom_SDA.Configure (Mode => RP.GPIO.Output,
                         Pull => RP.GPIO.Pull_Up,
                         Func => RP.GPIO.I2C);
   Eeprom_SCL.Configure (Mode => RP.GPIO.Output,
                         Pull => RP.GPIO.Pull_Up,
                         Func => RP.GPIO.I2C);
   Eeprom_I2C_Port.Configure (Baudrate => 400_000);

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
      Eeprom_I2C_Port.Mem_Read (Addr          => Eeprom_I2C_address,
                                Mem_Addr      => MY_ADDR,
                                Mem_Addr_Size => HAL.I2C.Memory_Size_8b,
                                Data          => Read_Data,
                                Status        => Read_Status,
                                Timeout       => 0);
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

end Read_One_Byte;
