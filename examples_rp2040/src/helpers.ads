with RP.GPIO;
with RP.I2C_Master;

package Helpers is

   procedure Initialize (SDA       : in out RP.GPIO.GPIO_Point;
                         SCL       : in out RP.GPIO.GPIO_Point;
                         I2C_Port  : in out RP.I2C_Master.I2C_Master_Port;
                         Trigger   : RP.GPIO.GPIO_Point;
                         Frequency : Natural);

   procedure Wait_For_Trigger_Fired;
   procedure Wait_For_Trigger_Resume;

end Helpers;
