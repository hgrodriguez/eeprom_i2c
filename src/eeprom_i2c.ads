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

with RP.I2C_Master;

package EEPROM_I2C is

   -----------------------------------------------------------------------------
   --  List of all implemented/supported chips
   --  The data sheets will be added into this repository
   type EEPROM_Chip is (EEC_MC24XX01 --  MicroChip 24XX01/24LC01B
                       );

   -----------------------------------------------------------------------------
   --  This is the EEPROM definition.
   --  We keep it as closed as possible to ensure, that changes have minimal
   --  ripple effect throughout.
   type EEPROM_Memory is abstract tagged private;
   type Any_EEPROM_Memory is access all EEPROM_Memory'Class;

   -----------------------------------------------------------------------------
   --  EEPROM status of last operation.
   type EEPROM_Status is (
                          --  all operations were successful
                          Ok,
                          --  returned, if the requestede memory address of
                          --  the EEPROM is out of range.
                          --  In this case, no I2C operation is started
                          Address_Out_Of_Range,
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
   --  As there are different sizes for EEPROMs, this function checks
   --  the memory address for being valid or out of range.
   function Is_Valid_Memory_Address (This     : in out EEPROM_Memory;
                                     Mem_Addr : HAL.UInt16)
                                     return Boolean is abstract;

   -----------------------------------------------------------------------------
   --  Returns the address size of this specific EEPROM.
   function Address_Size (This : in out EEPROM_Memory)
                          return HAL.I2C.I2C_Memory_Address_Size is abstract;

   -----------------------------------------------------------------------------
   --  Returns the size in bytes of this specific EEPROM.
   function Size_In_Bytes (This : in out EEPROM_Memory)
                           return HAL.UInt32 is abstract;

   -----------------------------------------------------------------------------
   --  Returns the size in bits of this specific EEPROM.
   function Size_In_Bits (This : in out EEPROM_Memory)
                          return HAL.UInt32 is abstract;

   -----------------------------------------------------------------------------
   --  Returns the number of pages of this specific EEPROM.
   function Number_Of_Pages (This : in out EEPROM_Memory)
                             return HAL.UInt16 is abstract;

   -----------------------------------------------------------------------------
   --  Returns the number of bytes per page for this specific EEPROM.
   function Bytes_Per_Page (This : in out EEPROM_Memory)
                            return HAL.UInt16 is abstract;

   -----------------------------------------------------------------------------
   --  Reads from the EEPROM memory.
   --  Mem_Addr: address to start the reading from
   --  Data    : storage to put the read data into
   --            the size of this array implies the number of bytes read
   --  Status  : status of the operation -> see above for details
   --  Timeout : time out in milliseconds can be specified.
   --            If the operation is not finished inside the time frame given,
   --            the operation will fail.
   procedure Read (This     : in out EEPROM_Memory;
                   Mem_Addr : HAL.UInt16;
                   Data     : out HAL.I2C.I2C_Data;
                   Status   : out EEPROM_Operation_Result;
                   Timeout  : Natural := 1000);

   -----------------------------------------------------------------------------
   --  Writes from the EEPROM memory.
   --  Mem_Addr: address to start the writing from
   --  Data    : storage to pull the write data from
   --            the size of this array implies the number of bytes written
   --  Status  : status of the operation -> see above for details
   --  Timeout : time out in milliseconds can be specified.
   --            If the operation is not finished inside the time frame given,
   --            the operation will fail.
   procedure Write (This     : in out EEPROM_Memory;
                    Mem_Addr : HAL.UInt16;
                    Data     : HAL.I2C.I2C_Data;
                    Status   : out EEPROM_Operation_Result;
                    Timeout  : Natural := 1000);

private
   -----------------------------------------------------------------------------
   --  Full definition for an EEPROM
   type EEPROM_Memory is abstract tagged record
      --  which chip is it
      Chip : EEPROM_Chip;
      --  the port where the EEPROM is connected to
      Port : HAL.I2C.Any_I2C_Port;
      --  the addres of the EEPROM on the bus
      Addr : HAL.I2C.I2C_Address;
   end record;

   -----------------------------------------------------------------------------
   --  Simulating a super() from other OO languages
   --  Sets all the, at this level, known components
   procedure Super (This : in out EEPROM_Memory;
                    Chip : EEPROM_Chip;
                    Port : HAL.I2C.Any_I2C_Port;
                    Addr : HAL.I2C.I2C_Address);

end EEPROM_I2C;
