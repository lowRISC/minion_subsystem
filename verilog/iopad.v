module iopad(input wire T, input wire I, output wire O, inout wire IO);

   parameter iostd = "LVTTL";
   parameter slew = "FAST";
   parameter iodrv = 24;

`ifdef XILINX
   
   // tri-state gate
   IOBUF #(
       .DRIVE(iodrv), // Specify the output drive strength
       .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
       .IOSTANDARD(iostd), // Specify the I/O standard
       .SLEW(slew) // Specify the output slew rate
    ) IOBUF_cmd_inst (
       .O(O),     // Buffer output
       .IO(IO),   // Buffer inout port (connect directly to top-level port)
       .I(I),     // Buffer input
       .T(T)      // 3-state enable input, high=input, low=output
    );

`else // !`ifdef XILINX

   assign O = IO;
   assign IO = T ? 1'bz : I;
   
`endif
   
endmodule
   
