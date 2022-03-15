with RP.Clock;

package body Helpers is

   procedure Initialize_I2C is
   begin
      --  standard initialization
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;

      --  as always, visual help is appreciated
      Pico.LED.Configure (RP.GPIO.Output);

      --  configure the I2C port
      Eeprom_SDA.Configure (Mode => RP.GPIO.Output,
                            Pull => RP.GPIO.Pull_Up,
                            Func => RP.GPIO.I2C);
      Eeprom_SCL.Configure (Mode => RP.GPIO.Output,
                            Pull => RP.GPIO.Pull_Up,
                            Func => RP.GPIO.I2C);
      Eeprom_I2C_Port.Configure (Baudrate => 400_000);

   end Initialize_I2C;

end Helpers;
