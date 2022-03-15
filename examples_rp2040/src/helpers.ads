with RP.Device;
with RP.GPIO;
with RP.I2C_Master;

package Helpers is

   --  Definitions of the connections to the EEPROM
   Eeprom_I2C_Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2C_0;

   procedure Initialize (SDA       : in out RP.GPIO.GPIO_Point;
                         SCL       : in out RP.GPIO.GPIO_Point;
                         Trigger   : RP.GPIO.GPIO_Point;
                         Frequency : Natural);

   procedure Wait_For_Trigger_Fired;
   procedure Wait_For_Trigger_Resume;

end Helpers;
