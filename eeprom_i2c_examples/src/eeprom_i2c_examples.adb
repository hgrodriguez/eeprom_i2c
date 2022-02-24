with HAL;
with HAL.I2C;

with RP.Clock;
with RP.Device;
with RP.GPIO;
with RP.I2C_Master;
with RP.Timer;

with Pico;

with EEPROM_I2C;

procedure Eeprom_I2c_Examples is

   use HAL;
   use HAL.I2C;

   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;
   Eeprom_SDA      : RP.GPIO.GPIO_Point renames Pico.GP0;
   Eeprom_SCL      : RP.GPIO.GPIO_Point renames Pico.GP1;

   Write_Bytes : array (EEPROM_I2C.Address_Range) of EEPROM_I2C.Eeprom_Byte;
   Read_Bytes  : array (EEPROM_I2C.Address_Range) of EEPROM_I2C.Eeprom_Byte;

   My_Byte     : EEPROM_I2C.Eeprom_Byte;

   My_Delay   : RP.Timer.Delays;

   Write_Status : HAL.I2C.I2C_Status;
   Read_Status  : HAL.I2C.I2C_Status;

   MY_ADDR      : constant HAL.UInt16 := 10 * 16 + 5;

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   RP.Device.Timer.Enable;
   RP.GPIO.Enable;

   Pico.LED.Configure (RP.GPIO.Output);
   Pico.LED.Set;

   Eeprom_SDA.Configure (Mode => RP.GPIO.Output,
                         Pull => RP.GPIO.Pull_Up,
                         Func => RP.GPIO.I2C);
   Eeprom_SCL.Configure (Mode => RP.GPIO.Output,
                         Pull => RP.GPIO.Pull_Up,
                         Func => RP.GPIO.I2C);
   Eeprom_I2C_Port.Configure (Baudrate => 400_000);

   loop
      --------------------------------------------------------------------
      --  Fill the bytes with data to write
      for I in EEPROM_I2C.Address_Range loop
         Write_Bytes (I) := EEPROM_I2C.Eeprom_Byte (I and 16#FF#);
      end loop;

      --------------------------------------------------------------------
      --  Write loop with data
      for I in EEPROM_I2C.Address_Range loop
         Write_Status := EEPROM_I2C.Write_Byte (This => Eeprom_I2C_Port,
                                                A    => I,
                                                B    => Write_Bytes (I));
         if Write_Status /= HAL.I2C.Ok then
            Pico.LED.Clear;
         end if;
         if I /= EEPROM_I2C.Address_Range'Last then
            RP.Timer.Delay_Milliseconds (This => My_Delay,
                                         Ms   => 5);
         end if;
      end loop;

      Pico.LED.Set;

      --------------------------------------------------------------------
      --  Read loop with data
      for I in EEPROM_I2C.Address_Range loop
         Read_Status := EEPROM_I2C.Read_Byte (This => Eeprom_I2C_Port,
                                              A    => I,
                                              B    => My_Byte);
         if Read_Status /= HAL.I2C.Ok then
            Pico.LED.Clear;
         end if;
         Read_Bytes (I) := My_Byte;
      end loop;

      loop
         Pico.LED.Set;
      end loop;
   end loop;

end Eeprom_I2c_Examples;
