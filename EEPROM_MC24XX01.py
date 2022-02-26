"""
"""

from machine import I2C, Pin
import time

class MC24XX01(object):

    @staticmethod
    def number_of_pages():
        return 16
    
    @staticmethod
    def number_of_bytes_per_page():
        return 8
    
    @staticmethod
    def number_of_bytes():
        return MC24XX01.number_of_pages() * MC24XX01.number_of_bytes_per_page()

    @staticmethod
    def address_size():
        return 8

    def __init__(self, i2c_bus, i2c_addr):
        self._i2c_bus = i2c_bus
        self._i2c_addr = i2c_addr

    def read(self, addr, nbytes):
        """Read one or more bytes from the EEPROM starting from a specific address"""
        return self._i2c_bus.readfrom_mem(self._i2c_addr,
                                          addr,
                                          nbytes,
                                          addrsize=self.address_size())

    def write(self, addr, buf):
        """Write one or more bytes to the EEPROM starting from a specific address"""
        offset = addr % self.number_of_bytes_per_page()
        partial = 0
        # partial page write
        if offset > 0:
            partial = self.number_of_bytes_per_page() - offset
            self._i2c_bus.writeto_mem(self._i2c_addr,
                                      addr,
                                      buf[0:partial],
                                      addrsize=self.address_size())
            time.sleep_ms(5)
            addr += partial
        # full page write
        for i in range(partial, len(buf), self.number_of_bytes_per_page()):
            self._i2c_bus.writeto_mem(self._i2c_addr,
                                      addr+i-partial,
                                      buf[i:i+8],
                                      addrsize=8)
            time.sleep_ms(5)

    def wipe(self):
        buf = b'\xff' * MC24XX01.number_of_bytes_per_page()
        for i in range(MC24XX01.number_of_pages()):
            self.write(i*MC24XX01.number_of_bytes_per_page(), buf)


LED = machine.Pin(25,machine.Pin.OUT)
LED.value(False)

Button = machine.Pin(16, machine.Pin.IN, machine.Pin.PULL_DOWN)

sda=machine.Pin(0)
scl=machine.Pin(1)
i2c=machine.I2C(0,sda=sda, scl=scl, freq=400000)
i2c_addr=0x50 #Set the I2C address of your EEPROM.

myEEPROM = MC24XX01(i2c, i2c_addr)
    
def wait_for_trigger_fired():
    while not Button.value():
        ##  wait for the button to be pressed
        pass

def wait_for_trigger_resume():
    while Button.value():
        ##  wait for the button to be pressed
        pass

def main():

##    while True:
##        LED.value(Button.value())

#####
#     print("I2C Devices : ")
#     print(i2c.scan())

    MY_ADDR = 37
#    My_Write_Buffer = b'\x5A'

    My_Write_Buffer = b'\xA5'
    
    wait_for_trigger_fired()
    myEEPROM.write(MY_ADDR, My_Write_Buffer)

    LED.value(True)

    while True:
        pass
    
    while True:
        wait_for_trigger_fired()
        LED.value(True)
        My_Read_Buffer = myEEPROM.read(MY_ADDR, 1)
        wait_for_trigger_resume()
        LED.value(False)
        
#     My_Write_Buffer = 'Diana'
#     My_Write_Buffer = b'\x5A'
#     My_Write_Buffer = b'\xA5'
#     
#     myEEPROM.write(MY_ADDR, My_Write_Buffer)
#     
#     # My_Read_Buffer = myEEPROM.read(0, myEEPROM.number_of_bytes())
#     My_Read_Buffer = myEEPROM.read(MY_ADDR, 1)
# 
#     print(My_Read_Buffer)
#     print('\n')
#         
#     myEEPROM.wipe()
#     My_Read_Buffer = myEEPROM.read(0, myEEPROM.number_of_bytes())
#     print(My_Read_Buffer)
#     print('\n')
    
if __name__ == "__main__":
    main ()
    