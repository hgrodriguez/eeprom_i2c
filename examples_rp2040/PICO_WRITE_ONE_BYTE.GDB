file bin/pico_write_one_byte
target extended-remote localhost:3333
load
break Pico_Write_One_Byte
set print element 0
