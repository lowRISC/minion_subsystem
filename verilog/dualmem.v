
module dualmem(clka, clkb, dina, dinb, addra, addrb, wea, web, douta, doutb, ena, enb);

   parameter rwidth = 13;
   parameter dw = 8;
   
   input clka, clkb;
   input [dw-1:0] dina, dinb;
   input [rwidth-1:0] addra, addrb;
   input [0:0]        wea, web;
   input [0:0]        ena, enb;
   output reg [dw-1:0]       douta, doutb;

`ifndef XILINX

   reg [dw-1:0]       mem [(1<<rwidth) -1:0]; // instantiate memory
   reg [rwidth-1:0]       ra, rb;                 // register read address

   // read operation
   always @(posedge clka)
     if (ena)
       begin
       ra <= addra;
       if (wea) mem[addra] <= dina;
       end
   
   assign douta = mem[ra];
   assign doutb = mem[rb];
   
   // write operation
   always@(posedge clkb)
     if (enb)
       begin
       rb <= addrb;
       if (web) mem[addrb] <= dinb;
       end
   
`else
   
   RAMB16_S2_S2 RAMB16_S1_inst_0 (
                                  .CLKA(clka),      // Port A Clock
                                  .CLKB(clkb),      // Port A Clock
                                  .DOA(douta[1:0]), // Port A 1-bit Data Output
                                  .ADDRA(addra),    // Port A 14-bit Address Input
                                  .DIA(dina[1:0]),  // Port A 1-bit Data Input
                                  .ENA(ena),        // Port A RAM Enable Input
                                  .SSRA(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEA(wea),        // Port A Write Enable Input
                                  .DOB(doutb[1:0]), // Port A 1-bit Data Output
                                  .ADDRB(addrb),    // Port A 14-bit Address Input
                                  .DIB(dinb[1:0]),  // Port A 1-bit Data Input
                                  .ENB(enb),        // Port A RAM Enable Input
                                  .SSRB(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEB(web)         // Port A Write Enable Input
                                  );

   RAMB16_S2_S2 RAMB16_S1_inst_1 (
                                  .CLKA(clka),      // Port A Clock
                                  .CLKB(clkb),      // Port A Clock
                                  .DOA(douta[3:2]), // Port A 1-bit Data Output
                                  .ADDRA(addra),    // Port A 14-bit Address Input
                                  .DIA(dina[3:2]),  // Port A 1-bit Data Input
                                  .ENA(ena),        // Port A RAM Enable Input
                                  .SSRA(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEA(wea),        // Port A Write Enable Input
                                  .DOB(doutb[3:2]), // Port A 1-bit Data Output
                                  .ADDRB(addrb),    // Port A 14-bit Address Input
                                  .DIB(dinb[3:2]),  // Port A 1-bit Data Input
                                  .ENB(enb),        // Port A RAM Enable Input
                                  .SSRB(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEB(web)         // Port A Write Enable Input
                                  );

   RAMB16_S2_S2 RAMB16_S1_inst_2 (
                                  .CLKA(clka),      // Port A Clock
                                  .CLKB(clkb),      // Port A Clock
                                  .DOA(douta[5:4]), // Port A 1-bit Data Output
                                  .ADDRA(addra),    // Port A 14-bit Address Input
                                  .DIA(dina[5:4]),  // Port A 1-bit Data Input
                                  .ENA(ena),        // Port A RAM Enable Input
                                  .SSRA(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEA(wea),        // Port A Write Enable Input
                                  .DOB(doutb[5:4]), // Port A 1-bit Data Output
                                  .ADDRB(addrb),    // Port A 14-bit Address Input
                                  .DIB(dinb[5:4]),  // Port A 1-bit Data Input
                                  .ENB(enb),        // Port A RAM Enable Input
                                  .SSRB(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEB(web)         // Port A Write Enable Input
                                  );

   RAMB16_S2_S2 RAMB16_S1_inst_3 (
                                  .CLKA(clka),      // Port A Clock
                                  .CLKB(clkb),      // Port A Clock
                                  .DOA(douta[7:6]), // Port A 1-bit Data Output
                                  .ADDRA(addra),    // Port A 14-bit Address Input
                                  .DIA(dina[7:6]),  // Port A 1-bit Data Input
                                  .ENA(ena),        // Port A RAM Enable Input
                                  .SSRA(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEA(wea),        // Port A Write Enable Input
                                  .DOB(doutb[7:6]), // Port A 1-bit Data Output
                                  .ADDRB(addrb),    // Port A 14-bit Address Input
                                  .DIB(dinb[7:6]),  // Port A 1-bit Data Input
                                  .ENB(enb),        // Port A RAM Enable Input
                                  .SSRB(1'b0),      // Port A Synchronous Set/Reset Input
                                  .WEB(web)         // Port A Write Enable Input
                                  );

`endif
   
endmodule // dualmem
