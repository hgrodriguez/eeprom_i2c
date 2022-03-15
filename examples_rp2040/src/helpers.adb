with RP.Clock;

with Pico;

package body Helpers is

   procedure Initialize_I2C (SDA : in out RP.GPIO.GPIO_Point;
                             SCL : in out RP.GPIO.GPIO_Point);

   The_Trigger : RP.GPIO.GPIO_Point;

   procedure Initialize  (SDA     : in out RP.GPIO.GPIO_Point;
                          SCL     : in out RP.GPIO.GPIO_Point;
                          Trigger : RP.GPIO.GPIO_Point) is
   begin
      Initialize_I2C (SDA, SCL);
      The_Trigger := Trigger;
      --  define a trigger input to enable oscilloscope tracking
      RP.GPIO.Configure (This => The_Trigger,
                         Mode => RP.GPIO.Input,
                         Pull => RP.GPIO.Pull_Down,
                         Func => RP.GPIO.SIO);
   end Initialize;

   procedure Wait_For_Trigger_Fired is
   begin
      loop
         exit when RP.GPIO.Get (The_Trigger);
      end loop;
   end Wait_For_Trigger_Fired;

   procedure Wait_For_Trigger_Resume is
   begin
      loop
         exit when not RP.GPIO.Get (The_Trigger);
      end loop;
   end Wait_For_Trigger_Resume;

   procedure Initialize_I2C  (SDA : in out RP.GPIO.GPIO_Point;
                              SCL : in out RP.GPIO.GPIO_Point) is
   begin
      --  standard initialization
      RP.Clock.Initialize (Pico.XOSC_Frequency);
      RP.Clock.Enable (RP.Clock.PERI);
      RP.Device.Timer.Enable;
      RP.GPIO.Enable;

      --  as always, visual help is appreciated
      Pico.LED.Configure (RP.GPIO.Output);

      --  configure the I2C port
      SDA.Configure (Mode => RP.GPIO.Output,
                            Pull => RP.GPIO.Pull_Up,
                            Func => RP.GPIO.I2C);
      SCL.Configure (Mode => RP.GPIO.Output,
                            Pull => RP.GPIO.Pull_Up,
                            Func => RP.GPIO.I2C);
      Eeprom_I2C_Port.Configure (Baudrate => 400_000);

   end Initialize_I2C;

end Helpers;
