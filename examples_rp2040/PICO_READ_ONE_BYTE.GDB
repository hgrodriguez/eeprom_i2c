file bin/pico_read_one_byte
target extended-remote localhost:3333
load
break Pico_Read_One_Byte
set print element 0
