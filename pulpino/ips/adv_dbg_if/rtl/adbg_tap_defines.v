//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tap_defines.v                                               ////
////                                                              ////
////                                                              ////
////  This file is part of the JTAG Test Access Port (TAP)        ////
////  http://www.opencores.org/projects/jtag/                     ////
////                                                              ////
////  Author(s):                                                  ////
////       Igor Mohor (igorm@opencores.org)                       ////
////                                                              ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 - 2003 Authors                            ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: tap_defines.v,v $
// Revision 1.1.1.1  2008-05-14 12:07:33  Nathan
// Original from OpenCores
//
// Revision 1.3  2004/03/02 17:39:45  mohor
// IDCODE_VALUE changed to Flextronics ID.
//
// Revision 1.2  2004/01/27 10:00:33  mohor
// Unused registers removed.
//
// Revision 1.1  2003/12/23 14:52:14  mohor
// Directory structure changed. New version of TAP.
//
//
//


// Define IDCODE Value
`define IDCODE_VALUE  32'h13631093 // fake Xilinx artix7
//"XXXX" &        -- version
//"0011011" &     -- family
//"000110001" &   -- array size
//"00001001001" & -- manufacturer
//"1";            -- required by 1149.1

// Length of the Instruction register
`define	IR_LENGTH	6

// Supported Instructions
`define EXTEST          6'b100110
`define SAMPLE_PRELOAD  6'b000001
`define IDCODE          6'b001001
`define DEBUG           6'b000010
`define MBIST           6'b000011
`define BYPASS          6'b111111
