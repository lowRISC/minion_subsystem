
module RAMBYTE (CLK, EN, WE, ADDR, DI, DO);

   input CLK;
   input EN;
   input WE;
   input [13 : 0] ADDR;
   input [7 : 0]  DI;
   output [7 : 0] DO;
   
   RAMB16_S1   RAMB16_inst_0 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[0]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[0]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );
   
   RAMB16_S1   RAMB16_inst_1 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[1]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[1]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

   RAMB16_S1   RAMB16_inst_2 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[2]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[2]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

   RAMB16_S1   RAMB16_inst_3 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[3]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[3]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

   RAMB16_S1   RAMB16_inst_4 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[4]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[4]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

   RAMB16_S1   RAMB16_inst_5 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[5]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[5]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

   RAMB16_S1   RAMB16_inst_6 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[6]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[6]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

   RAMB16_S1   RAMB16_inst_7 (
                              .CLK(CLK),      // Port A Clock
                              .DO(DO[7]),     // Port A 1-bit Data Output
                              .ADDR(ADDR[13:0]),    // Port A 14-bit Address Input
                              .EN(EN),        // Port A 1-bit Data Input
                              .DI(DI[7]),     // Port A RAM Enable Input
                              .SSR(1'b0),     // Port A Synchronous Set/Reset Input
                              .WE(WE)         // Port A Write Enable Input
                              );

endmodule
