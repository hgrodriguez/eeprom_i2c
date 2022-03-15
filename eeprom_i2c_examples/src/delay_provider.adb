with RP.Timer;

package body Delay_Provider is

   procedure Delay_MS (MS : Integer) is
      My_Delay : RP.Timer.Delays;
   begin
      RP.Timer.Delay_Milliseconds (This => My_Delay,
                                   Ms   => MS);
   end Delay_MS;

end Delay_Provider;
