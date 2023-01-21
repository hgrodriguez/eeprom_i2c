-----------------------------------------------------------------------------
--  Base class for the implementation of EEPROM memory connected via
--  I2C bus.
--
--  Copyright 2022 (C) Holger Rodriguez
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with HAL;
with HAL.I2C;

package EEPROM_I2C is

   -----------------------------------------------------------------------------
   --  List of all implemented/supported chips
   --  The data sheets will be added into this repository
   type EEPROM_Chip is (EEC_MC24XX01,   --  MicroChip 24XX01/24LC01B
                        EEC_MC24XX02,   --  MicroChip 24XX02/24LC02B
                        EEC_MC24XX16,   --  MicroChip 24LC16B
                        EEC_MC24XX64,   --  MicroChip 24XX64
                        EEC_MC24XX256,  --  MicroChip 24XX256
                        EEC_MC24XX512   --  MicroChip 24XX512
                       );

   -----------------------------------------------------------------------------
   --  Some EEPROMs have a so called t_WC time, which requires a break
   --  between writes in batches.
   --  This can be byte or page write cycles.
   --  As this library should not be tied to any platform,
   --  The user of the library has to provide the delay procedure
   type Proc_Delay_Callback_MS is not null access procedure (MS : Integer);

   -----------------------------------------------------------------------------
   --  This is the EEPROM definition.
   type EEPROM is interface;
   type Any_EEPROM is access all EEPROM'Class;

   type EEPROM_Memory ( --  which chip is it
                       C_Type_of_Chip        : EEPROM_Chip;
                       --  the size of addressing the EEPROM
                       C_Memory_Address_Size : HAL.I2C.I2C_Memory_Address_Size;
                       C_Size_In_Bytes       : HAL.UInt32;
                       C_Size_In_Bits        : HAL.UInt32;
                       C_Number_Of_Blocks    : HAL.UInt16;
                       C_Bytes_Per_Block     : HAL.UInt32;
                       C_Number_Of_Pages     : HAL.UInt16;
                       C_Bytes_Per_Page      : HAL.UInt16;
                       C_Max_Byte_Address    : HAL.UInt32;
                       C_Write_Delay_MS      : Integer;
                       C_Delay_Callback      : Proc_Delay_Callback_MS;
                       --  the address of the EEPROM on the bus
                       I2C_Addr            : HAL.I2C.I2C_Address;
                       --  the port where the EEPROM is connected to
                       I2C_Port            : not null HAL.I2C.Any_I2C_Port
                      )
   is new EEPROM with null record;
   type Any_EEPROM_Memory is access all EEPROM_Memory'Class;

   -----------------------------------------------------------------------------
   --  EEPROM status of last operation.
   type EEPROM_Status is (
                          --  all operations were successful
                          Ok,
                          --  returned, if the requested memory address of
                          --  the EEPROM is out of range:
                          --  Mem_Addr > Mem_Addr_Size
                          --  In this case, no I2C operation is started
                          Address_Out_Of_Range,
                          --  returned, if the requested data to write is
                          --  too big.
                          --  This means, that the relation:
                          --     Mem_Addr + Data'Size > Size_In_Bytes
                          Data_Too_Big,
                          --  Is set,
                          --  if anything is not OK with the I2C operation
                          I2C_Not_Ok
                         );

   -----------------------------------------------------------------------------
   --  Aggregation of the status of last operation.
   --  Always check this, before assuming, that it worked.
   type EEPROM_Operation_Result is record
      E_Status   : EEPROM_Status;
      --  Carries the last status of the I2C operation executed
      I2C_Status : HAL.I2C.I2C_Status;
   end record;

   -----------------------------------------------------------------------------
   --  Returns the type of chip of this specific EEPROM.
   function Type_of_Chip (This : in out EEPROM_Memory) return EEPROM_Chip;

   -----------------------------------------------------------------------------
   --  As there are different sizes for EEPROMs, this function checks
   --  the memory address for being valid or out of range.
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory;
                                     Mem_Addr : HAL.UInt32)
                                     return Boolean;

   -----------------------------------------------------------------------------
   --  Returns the address size of this specific EEPROM.
   function Mem_Addr_Size (This : in out EEPROM_Memory)
                           return HAL.I2C.I2C_Memory_Address_Size;

   -----------------------------------------------------------------------------
   --  Returns the size in bytes of this specific EEPROM.
   function Size_In_Bytes (This : in out EEPROM_Memory)
                           return HAL.UInt32;

   -----------------------------------------------------------------------------
   --  Returns the size in bits of this specific EEPROM.
   function Size_In_Bits (This : in out EEPROM_Memory)
                          return HAL.UInt32;

   -----------------------------------------------------------------------------
   --  Returns the number of blocks of this specific EEPROM.
   function Number_Of_Blocks (This : in out EEPROM_Memory)
                              return HAL.UInt16;

   -----------------------------------------------------------------------------
   --  Returns the number of blocks of this specific EEPROM.
   function Bytes_Per_Block (This : in out EEPROM_Memory)
                             return HAL.UInt32;

   -----------------------------------------------------------------------------
   --  Returns the number of pages of this specific EEPROM.
   function Number_Of_Pages (This : in out EEPROM_Memory)
                             return HAL.UInt16;

   -----------------------------------------------------------------------------
   --  Returns the number of bytes per page for this specific EEPROM.
   function Bytes_Per_Page (This : in out EEPROM_Memory)
                            return HAL.UInt16;

   type EEPROM_Effective_Address is record
      I2C_Address : HAL.I2C.I2C_Address;
      Mem_Addr    : HAL.UInt16;
   end record;

   -----------------------------------------------------------------------------
   --  Reads from the EEPROM memory.
   --  Mem_Addr   : address to start the reading from
   --  Data       : storage to put the read data into
   --               the size of this array implies the number of bytes read
   --  Status     : status of the operation -> see above for details
   --  Timeout_MS : time out in milliseconds can be specified.
   --               If the operation is not finished inside the
   --               time frame given, the operation will fail.
   procedure Read (This       : in out EEPROM_Memory'Class;
                   Mem_Addr   : HAL.UInt32;
                   Data       : out HAL.I2C.I2C_Data;
                   Status     : out EEPROM_Operation_Result;
                   Timeout_MS : Natural := 1000);

   -----------------------------------------------------------------------------
   --  Writes from the EEPROM memory.
   --  Mem_Addr   : address to start the writing from
   --  Data       : storage to pull the write data from
   --               the size of this array implies the number of bytes written
   --  Status     : status of the operation -> see above for details
   --  Timeout_MS : time out in milliseconds can be specified.
   --               If the operation is not finished inside the
   --               time frame given, the operation will fail.
   procedure Write (This       : in out EEPROM_Memory'Class;
                    Mem_Addr   : HAL.UInt32;
                    Data       : HAL.I2C.I2C_Data;
                    Status     : out EEPROM_Operation_Result;
                    Timeout_MS : Natural := 1000);

   -----------------------------------------------------------------------------
   --  Wipes the EEPROM memory.
   --  Status : status of the operation -> see above for details
   procedure Wipe (This   : in out EEPROM_Memory'Class;
                   Status : out EEPROM_Operation_Result);

private
   -----------------------------------------------------------------------------
   --  Constructs the final I2C address.
   --  Some EEPROMs have not only addresses, but blocks,
   --  which are encoded into the I2C address.
   function Construct_I2C_Address (This       : in out EEPROM_Memory'Class;
                                   Mem_Addr   : HAL.UInt32)
                                   return EEPROM_Effective_Address;

end EEPROM_I2C;
